package router

import (
	"fmt"
	"github.com/fapiper/onchain-access-control/pkg/service/auth"
	svcframework "github.com/fapiper/onchain-access-control/pkg/service/framework"
	"github.com/pkg/errors"
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
