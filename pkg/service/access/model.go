package access

import (
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/pkg/service/presentation/model"
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
