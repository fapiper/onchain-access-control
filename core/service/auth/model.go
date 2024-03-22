package auth

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"math/big"
)

type GrantRoleInput struct {
	RoleID string                         `json:"role_id"`
	Proof  contracts.IPolicyVerifierProof `json:"proof"`
	Inputs [20]*big.Int                   `json:"inputs"`
}

func (in GrantRoleInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}
