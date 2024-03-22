package credential

import (
	"fmt"

	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/internal/credential"
	"github.com/fapiper/onchain-access-control/core/service/common"
)

type BatchCreateCredentialsRequest struct {
	Requests []CreateCredentialRequest
}

type BatchCreateCredentialsResponse struct {
	Credentials []credential.Container
}

type CreateCredentialRequest struct {
	Issuer                             string         `json:"issuer" validate:"required"`
	FullyQualifiedVerificationMethodID string         `json:"issuerVerificationMethodId" validate:"required"`
	Subject                            string         `json:"subject" validate:"required"`
	Context                            string         `json:"context,omitempty"`
	SchemaID                           string         `json:"schemaId,omitempty"`
	Data                               map[string]any `json:"data,omitempty"`
	Expiry                             string         `json:"expiry,omitempty"`
	Revocable                          bool           `json:"revocable,omitempty"`
	Suspendable                        bool           `json:"suspendable,omitempty"`
	Evidence                           []any          `json:"evidence,omitempty"`
	// TODO(gabe) support more capabilities like signature type, format, evidence, and more.
}

// CreateCredentialResponse holds a resulting credential from credential creation, which is an XOR type:
// containing either a Data Integrity Proofed credential or a VC-JWT representation.
type CreateCredentialResponse struct {
	credential.Container `json:"credential,omitempty"`
}

type GetCredentialRequest struct {
	ID string `json:"id" validate:"required"`
}

type GetCredentialResponse struct {
	credential.Container `json:"credential,omitempty"`
}

type ListCredentialByIssuerRequest struct {
	Issuer string `json:"issuer" validate:"required"`
}

type ListCredentialBySubjectRequest struct {
	Subject string `json:"subject" validate:"required"`
}

type ListCredentialBySchemaRequest struct {
	Schema string `json:"schema" validate:"required"`
}

type ListCredentialsResponse struct {
	Credentials   []credential.Container `json:"credentials,omitempty"`
	NextPageToken string                 `json:"nextPageToken,omitempty"`
}

type DeleteCredentialRequest struct {
	ID string `json:"id" validate:"required"`
}

type GetCredentialStatusRequest struct {
	ID string `json:"id" validate:"required"`
}

type GetCredentialStatusResponse struct {
	Revoked   bool `json:"revoked" validate:"required"`
	Suspended bool `json:"suspended" validate:"required"`
}

type UpdateCredentialStatusRequest struct {
	ID        string `json:"id" validate:"required"`
	Revoked   bool   `json:"revoked" validate:"required"`
	Suspended bool   `json:"suspended" validate:"required"`
}

type UpdateCredentialStatusResponse struct {
	Status
}

type Status struct {
	// ID of the credentials whose status this object represents.
	ID        string `json:"id,omitempty"`
	Revoked   bool   `json:"revoked" validate:"required"`
	Suspended bool   `json:"suspended" validate:"required"`
}

type BatchUpdateCredentialStatusRequest struct {
	Requests []UpdateCredentialStatusRequest `json:"requests"`
}

type BatchUpdateCredentialStatusResponse struct {
	CredentialStatuses []Status `json:"credentialStatuses"`
}

type GetCredentialStatusListRequest struct {
	ID string `json:"id" validate:"required"`
}

type GetCredentialStatusListResponse struct {
	credential.Container `json:"credential,omitempty"`
}

func (csr CreateCredentialRequest) isStatusValid() bool {
	if csr.Revocable && csr.Suspendable {
		return false
	}
	return true
}

func (csr CreateCredentialRequest) hasStatus() bool {
	return csr.Suspendable || csr.Revocable
}

func (csr CreateCredentialRequest) hasEvidence() bool {
	return len(csr.Evidence) != 0
}

func (csr CreateCredentialRequest) validateEvidence() error {
	for _, e := range csr.Evidence {
		evidenceMap, ok := e.(map[string]any)
		if !ok {
			return fmt.Errorf("invalid evidence format")
		}

		_, idExists := evidenceMap["id"]
		_, typeExists := evidenceMap["type"]

		if !idExists || !typeExists {
			return fmt.Errorf("evidence missing required 'id' or 'type' field")
		}
	}

	return nil
}

func (csr CreateCredentialRequest) IsValid() error {
	if err := util.IsValidStruct(csr); err != nil {
		return err
	}
	return common.ValidateVerificationMethodID(csr.FullyQualifiedVerificationMethodID, csr.Issuer)
}
