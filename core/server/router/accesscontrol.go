package router

import (
	"fmt"
	"github.com/TBD54566975/ssi-sdk/util"
	framework "github.com/fapiper/onchain-access-control/core/framework/server"
	"github.com/fapiper/onchain-access-control/core/service/accesscontrol"
	svcframework "github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"net/http"
)

type AccessControlRouter struct {
	service *accesscontrol.Service
}

func NewAccessControlRouter(s svcframework.Service) (*AccessControlRouter, error) {
	if s == nil {
		return nil, errors.New("service cannot be nil")
	}
	service, ok := s.(*accesscontrol.Service)
	if !ok {
		return nil, fmt.Errorf("casting service: %s", s.Type())
	}
	return &AccessControlRouter{service: service}, nil
}

type CreateSessionRequest struct {
	// A JWE that encodes a session token
	SessionJWE []byte `json:"sessionJwe,omitempty" validate:"required"`
}

type CreateSessionResponse struct {
	// The created session
	Session accesscontrol.StoredSession `json:"session"`
}

// CreateSession godoc
//
//	@Summary		Creates a Session
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			request	body		CreateSessionRequest	true	"request body"
//	@Success		200		{object}	CreateSessionResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/access/session [put]
func (r AccessControlRouter) CreateSession(c *gin.Context) {
	var request CreateSessionRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid create session request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	stored, err := r.service.CreateSession(c, accesscontrol.CreateSessionInput{
		SessionJWE: request.SessionJWE,
	})
	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create session", http.StatusInternalServerError)
		return
	}

	resp := CreateSessionResponse{Session: *stored}
	framework.Respond(c, resp, http.StatusOK)
}

type RegisterResourceRequest accesscontrol.RegisterResourceInput

type RegisterResourceResponse = accesscontrol.RegisterResourceOutput

// RegisterResource godoc
//
//	@Summary		Registers a Resource
//	@Tags			Accesscontrol
//	@Accept			json
//	@Produce		json
//	@Param			request	body		RegisterResourceRequest	true	"request body"
//	@Success		200		{object}	RegisterResourceResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/access/resource [put]
func (r AccessControlRouter) RegisterResource(c *gin.Context) {
	var request RegisterResourceRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid register resource request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	resp, err := r.service.RegisterResource(c, accesscontrol.RegisterResourceInput(request))
	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not register resource", http.StatusInternalServerError)
		return
	}

	framework.Respond(c, resp, http.StatusOK)
}

type CreateAccessContextResponse struct {
	// The created session
	AccessContext accesscontrol.StoredAccessContext `json:"context"`
}

// CreateAccessContext godoc
//
//	@Summary		Creates an access context
//	@Tags			Accesscontrol
//	@Produce		json
//	@Success		200		{object}	CreateAccessContextResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/access/context [put]
func (r AccessControlRouter) CreateAccessContext(c *gin.Context) {

	stored, err := r.service.CreateAccessContext(c)
	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create access context", http.StatusInternalServerError)
		return
	}

	resp := CreateAccessContextResponse{AccessContext: *stored}
	framework.Respond(c, resp, http.StatusOK)
}

type CreatePolicyRequest struct {
	*accesscontrol.CreatePolicyRequest
}

type CreatePolicyResponse struct {
	*accesscontrol.CreatePolicyResponse
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
func (r AccessControlRouter) CreatePolicy(c *gin.Context) {
	var request CreatePolicyRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid create policy request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	storedPolicy, err := r.service.CreatePolicy(c, accesscontrol.CreatePolicyRequest{})

	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create policy", http.StatusInternalServerError)
		return
	}

	resp := CreatePolicyResponse{storedPolicy}
	framework.Respond(c, resp, http.StatusOK)
}
