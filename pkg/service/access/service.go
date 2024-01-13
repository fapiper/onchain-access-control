package access

import (
	"context"
	"fmt"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/pkg/service/framework"
	"github.com/fapiper/onchain-access-control/pkg/service/presentation"
	"github.com/fapiper/onchain-access-control/pkg/service/presentation/model"
	"github.com/fapiper/onchain-access-control/pkg/storage"
	"github.com/pkg/errors"
)

type Service struct {
	storage      *Storage
	presentation *presentation.Service
}

func (s Service) Type() framework.Type {
	return framework.Access
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.storage == nil {
		ae.AppendString("no storage configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("access service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewAccessService(s storage.ServiceStorage, p *presentation.Service) (*Service, error) {
	accessStorage, err := NewAccessStorage(s)

	if err != nil {
		return nil, sdkutil.LoggingErrorMsg(err, "instantiating storage for the access service")
	}

	service := Service{
		storage:      accessStorage,
		presentation: p,
	}
	if !service.Status().IsReady() {
		return nil, errors.New(service.Status().Message)
	}

	return &service, nil
}

// CreatePolicy uploads required policy artifacts to ipfs and deploys and registers an access policy on-chain.
func (s Service) CreatePolicy(ctx context.Context, request CreatePolicyRequest) (*CreatePolicyResponse, error) {
	if !request.IsValid() {
		return nil, errors.Errorf("invalid create session request: %+v", request)
	}

	uris, err := s.uploadPolicyArtifactsToIPFS(ctx, request.PresentationDefinitionID, request.Verifier)

	if err != nil {
		return nil, errors.Wrap(err, "could not upload policy artifacts to ipfs")
	}

	contract, err := s.deployAndRegisterPolicyContract(ctx, *uris)
	if err != nil {
		return nil, errors.Wrap(err, "could not deploy and register policy contract")
	}

	return &CreatePolicyResponse{PolicyContract: contract, URIs: *uris}, nil
}

func (s Service) uploadPolicyArtifactsToIPFS(ctx context.Context, definitionRequest *model.GetPresentationDefinitionRequest, verifier PolicyVerifier) (*PolicyURISet, error) {

	// get policy definition
	_, err := s.presentation.GetPresentationDefinition(ctx, *definitionRequest)
	if err != nil {
		return nil, errors.Wrap(err, "could not get presentation definition object")
	}

	// upload presentation definition, verifier keys and proof program to ipfs
	//

	return &PolicyURISet{
		PresentationDefinition: "",
		ProofProgram:           "",
		ProvingKey:             "",
		VerificationKey:        "",
	}, nil
}

func (s Service) deployAndRegisterPolicyContract(ctx context.Context, uris PolicyURISet) (string, error) {

	// send tx: deploy policy with uris
	// send tx: register policy contract in registry

	return "", nil
}
