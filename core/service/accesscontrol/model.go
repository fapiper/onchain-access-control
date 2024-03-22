package accesscontrol

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/fapiper/onchain-access-control/core/service/presentation/model"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
)

type CreatePolicyRequest struct {
	PresentationDefinitionID *model.GetPresentationDefinitionRequest `json:"presentation_definition_id"`
	Verifier                 PolicyVerifier                          `json:"verifier"`
}

func (cpr CreatePolicyRequest) IsValid() bool {
	return util.IsValidStruct(cpr) == nil
}

type PolicyVerifier struct {
	ContractAddress string `json:"contract_address"`
	ProvingKey      byte   `json:"proving_key"`
	VerificationKey byte   `json:"verification_key"`
}

type PolicyURISet struct {
	PresentationDefinition string `json:"presentation_definition"`
	ProofProgram           string `json:"proof_program"`
	ProvingKey             string `json:"proving_key"`
	VerificationKey        string `json:"verification_key,omitempty"`
}

type CreatePolicyResponse struct {
	// Address of the created policy contract
	PolicyContract string       `json:"policy_contract"`
	URIs           PolicyURISet `json:"uris"`
}

type RegisterResourceInput struct {
	Role     string `json:"role"`
	Policy   string `json:"policy"`
	Resource string `json:"resource"`
}

type RegisterResourceOutput struct {
	Role       string  `json:"role"`
	Policy     string  `json:"policy"`
	Permission []byte  `json:"permission"`
	Resource   string  `json:"resource"`
	Operations []uint8 `json:"operations"`
	DID        string  `json:"did"`
}

func (o RegisterResourceOutput) toParams(address persist.Address) rpc.RegisterResourceParams {
	return rpc.RegisterResourceParams{
		AccessContext: address,
		Role:          crypto.Keccak256Hash([]byte(o.Role)),
		Policy:        crypto.Keccak256Hash([]byte(o.Policy)),
		Permission:    crypto.Keccak256Hash(o.Permission),
		Resource:      crypto.Keccak256Hash([]byte(o.Resource)),
		Operations:    o.Operations, // read + write
		DID:           crypto.Keccak256Hash([]byte(o.DID)),
	}
}

func (in RegisterResourceInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}

type CreateSessionInput struct {
	SessionJWE []byte `json:"jwe,omitempty" validate:"required"`
}

func (in CreateSessionInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}

type VerifySessionInput struct {
	RoleID       string        `json:"role"`
	SessionToken keyaccess.JWT `json:"jwt,omitempty" validate:"required"`
}

type VerifySessionOutput struct {
	// Whether the Session was verified.
	Verified bool `json:"verified"`

	// The session token that was checked against.
	SessionJWT keyaccess.JWT `json:"jwt"`

	// When Verified == false, the reason why it wasn't verified.
	Reason string `json:"reason,omitempty"`
}
