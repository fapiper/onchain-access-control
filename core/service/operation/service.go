package operation

import (
	"context"
	"fmt"
	opstorage "github.com/fapiper/onchain-access-control/core/service/operation/storage"
	"github.com/fapiper/onchain-access-control/core/service/operation/submission"
	"github.com/fapiper/onchain-access-control/core/service/presentation/model"
	prestorage "github.com/fapiper/onchain-access-control/core/service/presentation/storage"
	"strings"

	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/goccy/go-json"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"

	"github.com/fapiper/onchain-access-control/core/service/framework"
	manifestmodel "github.com/fapiper/onchain-access-control/core/service/manifest/model"
	manifeststg "github.com/fapiper/onchain-access-control/core/service/manifest/storage"
	"github.com/fapiper/onchain-access-control/core/service/operation/credential"
	"github.com/fapiper/onchain-access-control/core/storage"
)

type Service struct {
	storage *Storage
}

func (s Service) Type() framework.Type {
	return framework.Operation
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.storage == nil {
		ae.AppendString("no storage configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("operation service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func (s Service) ListOperations(ctx context.Context, request ListOperationsRequest) (*ListOperationsResponse, error) {
	if err := request.Validate(); err != nil {
		return nil, errors.Wrap(err, "invalid request")
	}

	ops, err := s.storage.ListOperations(ctx, request.Parent, request.Filter, request.PageRequest.ToServicePage())
	if err != nil {
		return nil, errors.Wrap(err, "fetching ops from storage")
	}

	resp := ListOperationsResponse{
		Operations:    make([]Operation, len(ops.StoredOperations)),
		NextPageToken: ops.NextPageToken,
	}
	for i, op := range ops.StoredOperations {
		op := op
		newOp, err := ServiceModel(op)
		if err != nil {
			logrus.WithError(err).WithField("operation_id", op.ID).Error("converting to storage operations to model")
			continue
		}
		resp.Operations[i] = *newOp
	}
	return &resp, nil
}

type ServiceModelFunc func(any) any

// ServiceModel converts a storage.StoredOperation to an Operation. The Result.Response field is introspected and
// converted into the service layer's model.
func ServiceModel(op opstorage.StoredOperation) (*Operation, error) {
	newOp := &Operation{
		ID:   op.ID,
		Done: op.Done,
		Result: Result{
			Error: op.Error,
		},
	}

	if len(op.Response) > 0 {
		switch {
		case strings.HasPrefix(op.ID, submission.ParentResource):
			var s prestorage.StoredSubmission
			if err := json.Unmarshal(op.Response, &s); err != nil {
				return nil, errors.Wrap(err, "unmarshalling submission response")
			}
			newOp.Result.Response = model.ServiceModel(&s)
		case strings.HasPrefix(op.ID, credential.ParentResource):
			var s manifeststg.StoredResponse
			if err := json.Unmarshal(op.Response, &s); err != nil {
				return nil, errors.Wrap(err, "unmarshalling cred response")
			}
			newOp.Result.Response = manifestmodel.ServiceModel(&s)
		default:
			return nil, errors.New("unknown response type")
		}
	}

	return newOp, nil
}

func (s Service) GetOperation(ctx context.Context, request GetOperationRequest) (*Operation, error) {
	if err := request.Validate(); err != nil {
		return nil, errors.Wrap(err, "invalid request")
	}

	storedOp, err := s.storage.GetOperation(ctx, request.ID)
	if err != nil {
		return nil, errors.Wrap(err, "fetching from storage")
	}
	return ServiceModel(storedOp)
}

func (s Service) CancelOperation(ctx context.Context, request CancelOperationRequest) (*Operation, error) {
	if err := request.Validate(); err != nil {
		return nil, errors.Wrap(err, "invalid request")
	}

	storedOp, err := s.storage.CancelOperation(ctx, request.ID)
	if err != nil {
		return nil, errors.Wrap(err, "marking as done")
	}
	return ServiceModel(*storedOp)
}

func NewOperationService(s storage.ServiceStorage) (*Service, error) {
	opStorage, err := NewOperationStorage(s)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "creating operation storage")
	}
	service := &Service{storage: opStorage}
	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}
	return service, nil
}
