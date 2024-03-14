package router

import (
	"fmt"
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/contracts"
	framework "github.com/fapiper/onchain-access-control/core/framework/server"
	"github.com/fapiper/onchain-access-control/core/service/auth"
	svcframework "github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"math/big"
	"net/http"
)

const (
	RoleIdentifierParam = "id"
	SessionIDParam      = "id"
)

type AuthRouter struct {
	service *auth.Service
}

func NewAuthRouter(s svcframework.Service) (*AuthRouter, error) {
	if s == nil {
		return nil, errors.New("service cannot be nil")
	}
	service, ok := s.(*auth.Service)
	if !ok {
		return nil, fmt.Errorf("casting service: %s", s.Type())
	}
	return &AuthRouter{service: service}, nil
}

type CreateSessionRequest struct {
	// A JWE that encodes a session token
	SessionJWE []byte `json:"sessionJwe,omitempty" validate:"required"`
}

type CreateSessionResponse struct {
	// The created session
	Session auth.StoredSession `json:"session"`
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
//	@Router			/auth/session [put]
func (r AuthRouter) CreateSession(c *gin.Context) {
	var request CreateSessionRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid create session request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	stored, err := r.service.CreateSession(c, auth.CreateSessionInput{
		SessionJWE: request.SessionJWE,
	})
	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create session", http.StatusInternalServerError)
		return
	}

	resp := CreateSessionResponse{Session: *stored}
	framework.Respond(c, resp, http.StatusOK)
}

type GrantRoleRequest struct {
	Proof  contracts.IPolicyVerifierProof `json:"proof"`
	Inputs [20]*big.Int                   `json:"inputs"`
}

type GrantRoleResponse struct {
	// The created role
	Role auth.Role `json:"role"`
}

// GrantRole godoc
//
//	@Summary		Grants a role to this resourceuser instance
//	@Tags			Auth
//	@Accept			json
//	@Produce		json
//	@Param			id		path		string				true	"ID"
//	@Param			request	body		GrantRoleRequest	true	"request body"
//	@Success		200		{object}	GrantRoleResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/auth/session [put]
func (r AuthRouter) GrantRole(ctx *gin.Context) {
	roleIdentifierParam := framework.GetParam(ctx, RoleIdentifierParam)
	if roleIdentifierParam == nil {
		framework.LoggingRespondErrMsg(ctx, "grant role request missing id parameter", http.StatusBadRequest)
		return
	}

	var request GrantRoleRequest
	if err := framework.Decode(ctx.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(ctx, err, "invalid grant role request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(ctx, err, http.StatusBadRequest)
		return
	}

	stored, err := r.service.GrantRole(ctx, auth.GrantRoleInput{RoleID: *roleIdentifierParam, Proof: request.Proof, Inputs: request.Inputs})

	if err != nil {
		framework.LoggingRespondErrWithMsg(ctx, err, "could not grant role", http.StatusInternalServerError)
		return
	}

	response := GrantRoleResponse{Role: *stored}
	framework.Respond(ctx, response, http.StatusOK)
}
