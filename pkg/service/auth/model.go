package auth

import (
	"github.com/TBD54566975/ssi-sdk/util"
)

type CreateSessionRequest struct {
	SessionJWE []byte `json:"jwe,omitempty" validate:"required"`
}

func (csr CreateSessionRequest) IsValid() bool {
	return util.IsValidStruct(csr) == nil
}
