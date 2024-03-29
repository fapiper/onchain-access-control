package schema

import (
	"github.com/TBD54566975/ssi-sdk/credential/schema"
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/server/pagination"
	"github.com/fapiper/onchain-access-control/core/service/common"
)

type CreateSchemaRequest struct {
	Name                               string            `json:"name" validate:"required"`
	Description                        string            `json:"description,omitempty"`
	Schema                             schema.JSONSchema `json:"schema" validate:"required"`
	Issuer                             string            `json:"issuer,omitempty"`
	FullyQualifiedVerificationMethodID string            `json:"fullyQualifiedVerificationMethodId,omitempty"`
}

// IsCredentialSchemaRequest returns true if the request is for a credential schema
func (csr CreateSchemaRequest) IsCredentialSchemaRequest() bool {
	return csr.Issuer != "" && csr.FullyQualifiedVerificationMethodID != ""
}

func (csr CreateSchemaRequest) IsValid() error {
	if err := util.IsValidStruct(csr); err != nil {
		return err
	}
	if csr.FullyQualifiedVerificationMethodID != "" && csr.Issuer != "" {
		return common.ValidateVerificationMethodID(csr.FullyQualifiedVerificationMethodID, csr.Issuer)
	}
	return nil
}

type CreateSchemaResponse struct {
	ID               string                  `json:"id"`
	Type             schema.VCJSONSchemaType `json:"type"`
	Schema           *schema.JSONSchema      `json:"schema,omitempty"`
	CredentialSchema *keyaccess.JWT          `json:"credentialSchema,omitempty"`
}

type ListSchemasRequest struct {
	PageRequest *pagination.PageRequest
}

type ListSchemasResponse struct {
	Schemas       []GetSchemaResponse `json:"schemas,omitempty"`
	NextPageToken string              `json:"nextPageToken,omitempty"`
}

type GetSchemaRequest struct {
	ID string `json:"id" validate:"required"`
}

type GetSchemaResponse struct {
	ID               string                  `json:"id"`
	Type             schema.VCJSONSchemaType `json:"type"`
	Schema           *schema.JSONSchema      `json:"schema,omitempty"`
	CredentialSchema *keyaccess.JWT          `json:"credentialSchema,omitempty"`
}

type DeleteSchemaRequest struct {
	ID string `json:"id" validate:"required"`
}
