package accesscontrol

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/service/presentation/model"
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

type CreateSessionInput struct {
	SessionJWE []byte `json:"jwe,omitempty" validate:"required"`
}

func (in CreateSessionInput) IsValid() bool {
	return util.IsValidStruct(in) == nil
}

type VerifySessionInput struct {
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
