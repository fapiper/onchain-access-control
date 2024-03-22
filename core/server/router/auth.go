package router

import (
	"fmt"
	"github.com/TBD54566975/ssi-sdk/util"
	framework "github.com/fapiper/onchain-access-control/core/framework/server"
	"github.com/fapiper/onchain-access-control/core/service/auth"
	svcframework "github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/gin-gonic/gin"
	"github.com/lestrrat-go/jwx/v2/jwt"
	"github.com/pkg/errors"
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

type StartSessionResponse struct {
	// The created session
	Session jwt.Token `json:"session"`
	// The created session
	SignedToken []byte `json:"signed_token"`
}

// StartSession godoc
//
//	@Summary		Starts a Session
//	@Tags			Auth
//	@Produce		json
//	@Success		200		{object}	StartSessionResponse
//	@Failure		400		{string}	string	"Bad request"
//	@Failure		500		{string}	string	"Internal server error"
//	@Router			/auth/session [put]
func (r AuthRouter) StartSession(c *gin.Context) {

	token, signedToken, err := r.service.StartSession(c)
	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not start session", http.StatusInternalServerError)
		return
	}

	resp := StartSessionResponse{Session: *token, SignedToken: *signedToken}
	framework.Respond(c, resp, http.StatusOK)
}

type GrantRoleRequest struct {
	Proof  any `json:"proof"`
	Inputs any `json:"inputs"`
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

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(ctx, err, http.StatusBadRequest)
		return
	}

	stored, err := r.service.GrantRole(ctx, auth.GrantRoleInput{RoleID: *roleIdentifierParam, Proof: auth.Proof, Inputs: auth.Inputs})

	if err != nil {
		framework.LoggingRespondErrWithMsg(ctx, err, "could not grant role", http.StatusInternalServerError)
		return
	}

	response := GrantRoleResponse{Role: *stored}
	framework.Respond(ctx, response, http.StatusOK)
}
