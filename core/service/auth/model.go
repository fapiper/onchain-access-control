package auth

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"math/big"
)

type StartSessionInput struct {
	Audience []string `json:"aud"`
}

func (in StartSessionInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}

type CreateSessionInput struct {
	SessionJWE []byte `json:"jwe,omitempty" validate:"required"`
}

func (in CreateSessionInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}

type VerifySessionInput struct {
	SessionJWT keyaccess.JWT `json:"jwt,omitempty" validate:"required"`
}

type VerifySessionOutput struct {
	// Whether the Session was verified.
	Verified bool `json:"verified"`

	// The session token that was checked against.
	SessionJWT keyaccess.JWT `json:"jwt"`

	// When Verified == false, the reason why it wasn't verified.
	Reason string `json:"reason,omitempty"`
}

type GrantRoleInput struct {
	RoleID string                         `json:"role_id"`
	Proof  contracts.IPolicyVerifierProof `json:"proof"`
	Inputs [20]*big.Int                   `json:"inputs"`
}

func (in GrantRoleInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}
