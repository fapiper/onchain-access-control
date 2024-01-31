package router

import (
	"fmt"
	"github.com/TBD54566975/ssi-sdk/util"
	framework "github.com/fapiper/onchain-access-control/core/framework/server"
	"github.com/fapiper/onchain-access-control/core/service/access"
	svcframework "github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"net/http"
)

type AccessRouter struct {
	service *access.Service
}

func NewAccessRouter(s svcframework.Service) (*AccessRouter, error) {
	if s == nil {
		return nil, errors.New("service cannot be nil")
	}
	service, ok := s.(*access.Service)
	if !ok {
		return nil, fmt.Errorf("casting service: %s", s.Type())
	}
	return &AccessRouter{service: service}, nil
}

type CreatePolicyRequest struct {
	*access.CreatePolicyRequest
}

type CreatePolicyResponse struct {
	*access.CreatePolicyResponse
}

// CreatePolicy godoc
//
//	@Summary		Creates an access policy
//	@Tags			Access
//	@Accept			json
//	@Produce		json
//	@Param			request	body		CreatePolicyRequest	true	"request body"
//	@Success		200		{object}	CreatePolicyResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/access/policy [put]
func (ar AccessRouter) CreatePolicy(c *gin.Context) {
	var request CreatePolicyRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid create policy request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	storedPolicy, err := ar.service.CreatePolicy(c, access.CreatePolicyRequest{})

	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create policy", http.StatusInternalServerError)
		return
	}

	resp := CreatePolicyResponse{storedPolicy}
	framework.Respond(c, resp, http.StatusOK)
}
