package authorize

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/service/persist"
)

type GrantRoleInput struct {
	RoleContext   persist.Address `json:"role_context"`
	RoleId        string          `json:"role_id"`
	PolicyContext persist.Address `json:"policy_context"`
	PolicyId      string          `json:"policy_id"`
}

func (in GrantRoleInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}
