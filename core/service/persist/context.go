package persist

import (
	"database/sql/driver"
	"fmt"
	"github.com/ethereum/go-ethereum/crypto"
	"strings"
)

// PolicyIdentifier represents an identifier for a policy within an access context
type PolicyIdentifier struct {
	ContextID [32]byte `json:"context_id"`
	PolicyID  [32]byte `json:"policy_id"`
}

// NewPolicyIdentifier creates a new token identifiers
func NewPolicyIdentifier(contextID [32]byte, policyID [32]byte) PolicyIdentifier {
	return PolicyIdentifier{
		ContextID: contextID,
		PolicyID:  policyID,
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
	ContextID [32]byte `json:"context_id"`
	RoleID    [32]byte `json:"role_id"`
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
		ContextID: crypto.Keccak256Hash([]byte(contextID)),
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
