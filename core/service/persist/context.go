package persist

import (
	"database/sql/driver"
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"strings"
)

// PolicyIdentifier represents an identifier for a policy within an access context
type PolicyIdentifier struct {
	ContextID common.Hash `json:"context_id"`
	PolicyID  common.Hash `json:"policy_id"`
}

// NewPolicyIdentifier creates a new token identifiers
//func NewPolicyIdentifier(contextID common.Hash, policyID common.Hash) PolicyIdentifier {
//	return PolicyIdentifier{
//		ContextID: contextID,                                                                                      // [32]byte(common.FromHex("0xb847a0ab3c84cfd0e0d826306fdd832d83b712583d6c2659850a2f7a866c96ce")),
//		PolicyID:  [32]byte(common.FromHex("0x44cc95fcac4cdc6a7c4b6d1f14643ba6ce89542b47dcba98b79ed3173efc13e6")), // policyID,  //
//	}
//}

// NewPolicyIdentifier creates a new token identifiers
func NewPolicyIdentifier(contextID string, policyID string) PolicyIdentifier {
	return PolicyIdentifier{
		ContextID: crypto.Keccak256Hash([]byte(contextID)), // [32]byte(common.FromHex("0xb847a0ab3c84cfd0e0d826306fdd832d83b712583d6c2659850a2f7a866c96ce"))
		PolicyID:  crypto.Keccak256Hash([]byte(policyID)),
	}
}

func (p PolicyIdentifier) String() string {
	return fmt.Sprintf("%s+%s", p.ContextID, p.PolicyID)
}

// Value implements the driver.Valuer interface
func (p PolicyIdentifier) Value() (driver.Value, error) {
	return p.String(), nil
}

// RoleIdentifier represents an identifier for a role within an access context
type RoleIdentifier struct {
	ContextID common.Hash `json:"context_id"`
	RoleID    common.Hash `json:"role_id"`
}

// Role represents an identifier for a role within an access context
type Role struct {
	ContextID string `json:"context_id"`
	RoleID    string `json:"role_id"`
}

// ParseRoleFromIdentifierString Parses string to Role type
func ParseRoleFromIdentifierString(data string) (*Role, error) {
	res := strings.Split(data, "+")
	if len(res) != 2 {
		return nil, fmt.Errorf("invalid role identifier format")
	}
	role := Role{
		ContextID: res[0],
		RoleID:    res[1],
	}
	return &role, nil
}

// NewRoleIdentifier creates a new token identifiers
func NewRoleIdentifier(contextID string, roleID string) RoleIdentifier {
	return RoleIdentifier{
		ContextID: crypto.Keccak256Hash([]byte(contextID)), // [32]byte(common.FromHex("0xb847a0ab3c84cfd0e0d826306fdd832d83b712583d6c2659850a2f7a866c96ce"))
		RoleID:    crypto.Keccak256Hash([]byte(roleID)),
	}
}

func (r RoleIdentifier) String() string {
	return fmt.Sprintf("%s+%s", r.ContextID, r.RoleID)
}

// Value implements the driver.Valuer interface
func (r RoleIdentifier) Value() (driver.Value, error) {
	return r.String(), nil
}
