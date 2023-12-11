package router

import (
	"fmt"
	"github.com/TBD54566975/ssi-sdk/util"
	framework "github.com/fapiper/onchain-access-control/pkg/framework/server"
	"github.com/fapiper/onchain-access-control/pkg/service/auth"
	svcframework "github.com/fapiper/onchain-access-control/pkg/service/framework"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
	"net/http"
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
func (ar AuthRouter) CreateSession(c *gin.Context) {
	var request CreateSessionRequest
	if err := framework.Decode(c.Request, &request); err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "invalid create session request", http.StatusBadRequest)
		return
	}

	if err := util.IsValidStruct(request); err != nil {
		framework.LoggingRespondError(c, err, http.StatusBadRequest)
		return
	}

	storedSession, err := ar.service.CreateSession(c, auth.CreateSessionRequest{
		SessionJWE: request.SessionJWE,
	})

	if err != nil {
		framework.LoggingRespondErrWithMsg(c, err, "could not create session", http.StatusInternalServerError)
		return
	}

	resp := CreateSessionResponse{Session: *storedSession}
	framework.Respond(c, resp, http.StatusOK)
}
