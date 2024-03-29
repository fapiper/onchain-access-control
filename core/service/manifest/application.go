package manifest

import (
	"context"
	"fmt"
	"github.com/fapiper/onchain-access-control/core/service/manifest/model"
	"strings"

	"github.com/TBD54566975/ssi-sdk/credential/manifest"
	errresp "github.com/TBD54566975/ssi-sdk/error"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/lestrrat-go/jwx/v2/jws"

	didint "github.com/fapiper/onchain-access-control/core/internal/did"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/service/credential"
)

// validateCredentialApplication validates the credential application's signature(s) in addition to making sure it
// is a valid credential application, and complies with its corresponding manifest. it returns the ids of unfulfilled
// input descriptors along with an error if validation fails.
func (s Service) validateCredentialApplication(ctx context.Context, credManifest manifest.CredentialManifest, request model.SubmitApplicationRequest) (inputDescriptorIDs []string, err error) {
	// parse headers
	headers, err := keyaccess.GetJWTHeaders([]byte(request.ApplicationJWT.String()))
	if err != nil {
		err = sdkutil.LoggingErrorMsg(err, "could not parse JWT headers")
		return
	}
	jwtKID, ok := headers.Get(jws.KeyIDKey)
	if !ok {
		err = sdkutil.LoggingNewError("JWT does not contain a kid")
		return
	}
	kid, ok := jwtKID.(string)
	if !ok {
		err = sdkutil.LoggingNewError("JWT kid is not a string")
		return
	}

	// validate the payload's signature
	if verificationErr := didint.VerifyTokenFromDID(ctx, s.didResolver, request.ApplicantDID, kid, request.ApplicationJWT); verificationErr != nil {
		err = sdkutil.LoggingErrorMsgf(err, "could not verify application<%s>'s signature", request.Application.ID)
		return
	}

	// validate the application
	credApp := request.Application
	if credErr := credApp.IsValid(); credErr != nil {
		err = sdkutil.LoggingErrorMsg(credErr, "application is not valid")
		return
	}

	// next, validate that the credential(s) provided in the application are valid
	unfulfilledInputDescriptorIDs, validationErr := manifest.IsValidCredentialApplicationForManifest(credManifest, request.ApplicationJSON)
	if validationErr != nil {
		resp := errresp.GetErrorResponse(validationErr)
		// a valid error response means this is an application level error, and we should return a credential denial
		if resp.Valid {
			if len(unfulfilledInputDescriptorIDs) > 0 {
				var reasons []string
				for id, reason := range unfulfilledInputDescriptorIDs {
					inputDescriptorIDs = append(inputDescriptorIDs, id)
					reasons = append(reasons, fmt.Sprintf("%s: %s", id, reason))
				}
				err = errresp.NewErrorResponsef(DenialResponse, "unfilled input descriptor(s): %s", strings.Join(reasons, ", "))
				return
			}
			err = errresp.NewErrorResponseWithError(DenialResponse, resp.Err)
			return
		}

		// otherwise, we have an internal error and  set the error to the value of the errResp's error
		err = sdkutil.LoggingErrorMsgf(resp.Err, "could not validate application: %s", credApp.ID)
		return
	}

	// signature and validity checks for each credential submitted with the application
	for _, credentialContainer := range request.Credentials {
		verificationResult, verificationErr := s.credential.VerifyCredential(ctx, credential.VerifyCredentialRequest{
			DataIntegrityCredential: credentialContainer.Credential,
			CredentialJWT:           credentialContainer.CredentialJWT,
		})

		if verificationErr != nil {
			err = sdkutil.LoggingNewErrorf("could not verify credential: %s", credentialContainer.Credential.ID)
			return
		}

		if !verificationResult.Verified {
			err = sdkutil.LoggingNewErrorf("submitted credential<%s> is not valid: %s", credentialContainer.Credential.ID, verificationResult.Reason)
			return
		}
	}
	return
}
