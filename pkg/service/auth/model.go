package auth

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/internal/keyaccess"
)

type CreateSessionRequest struct {
	SessionJWE []byte `json:"jwe,omitempty" validate:"required"`
}

func (csr CreateSessionRequest) IsValid() bool {
	return util.IsValidStruct(csr) == nil
}

type VerifySessionRequest struct {
	SessionJWT keyaccess.JWT `json:"jwt,omitempty" validate:"required"`
}

type VerifySessionResponse struct {
	// Whether the Session was verified.
	Verified bool `json:"verified"`

	// The session token that was checked against.
	SessionJWT keyaccess.JWT `json:"jwt"`

	// When Verified == false, the reason why it wasn't verified.
	Reason string `json:"reason,omitempty"`
}
