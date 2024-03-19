package accesscontrol

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/did/resolution"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/fapiper/onchain-access-control/core/config"
	didint "github.com/fapiper/onchain-access-control/core/internal/did"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/internal/util"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/keystore"
	"github.com/fapiper/onchain-access-control/core/service/presentation"
	"github.com/fapiper/onchain-access-control/core/service/presentation/model"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/fapiper/onchain-access-control/core/storage"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/lestrrat-go/jwx/v2/jwe"
	"github.com/pkg/errors"
)

type ServiceFactory func(storage.Tx) (*Service, error)

type Service struct {
	storageClient *Storage
	presentation  *presentation.Service
	ipfsClient    *shell.Shell
	rpcService    *rpc.Service
	keystore      *keystore.Service
	resolver      resolution.Resolver
}

func (s Service) Type() framework.Type {
	return framework.Access
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.storageClient == nil {
		ae.AppendString("no storage configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("access service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewAccessControlService(config config.AuthServiceConfig, s storage.ServiceStorage, p *presentation.Service, r resolution.Resolver, k *keystore.Service, rpcService *rpc.Service, ipfsClient *shell.Shell) (*Service, error) {
	encrypter, decrypter, err := keystore.NewServiceEncryption(s, config.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating new encryption")
	}

	factory := NewAccessControlServiceFactory(s, p, r, k, encrypter, decrypter, rpcService, ipfsClient)
	return factory(s)
}

func NewAccessControlServiceFactory(s storage.ServiceStorage, p *presentation.Service, r resolution.Resolver, k *keystore.Service, encrypter encryption.Encrypter, decrypter encryption.Decrypter, rpcService *rpc.Service, ipfsClient *shell.Shell) ServiceFactory {
	return func(tx storage.Tx) (*Service, error) {
		// Next, instantiate the key storage
		sc, err := NewAccessControlStorage(s, encrypter, decrypter, tx)

		if err != nil {
			return nil, sdkutil.LoggingErrorMsg(err, "instantiating storage for the accesscontrol service")
		}

		service := Service{
			storageClient: sc,
			keystore:      k,
			resolver:      r,
			rpcService:    rpcService,
			ipfsClient:    ipfsClient,
		}
		if !service.Status().IsReady() {
			return nil, errors.New(service.Status().Message)
		}
		return &service, nil
	}
}

// CreatePolicy uploads required policy artifacts to ipfs and deploys and registers an access policy on-chain.
func (s Service) CreatePolicy(ctx context.Context, request CreatePolicyRequest) (*CreatePolicyResponse, error) {
	if !request.IsValid() {
		return nil, errors.Errorf("invalid create session request: %+v", request)
	}

	uris, err := s.uploadPolicyArtifactsToIPFS(ctx, request.PresentationDefinitionID, request.Verifier)

	if err != nil {
		return nil, errors.Wrap(err, "could not upload policy artifacts to ipfs")
	}

	contract, err := s.deployAndRegisterPolicyContract(ctx, *uris)
	if err != nil {
		return nil, errors.Wrap(err, "could not deploy and register policy contract")
	}

	return &CreatePolicyResponse{PolicyContract: contract, URIs: *uris}, nil
}

func (s Service) uploadPolicyArtifactsToIPFS(ctx context.Context, definitionRequest *model.GetPresentationDefinitionRequest, verifier PolicyVerifier) (*PolicyURISet, error) {

	// get policy definition
	_, err := s.presentation.GetPresentationDefinition(ctx, *definitionRequest)
	if err != nil {
		return nil, errors.Wrap(err, "could not get presentation definition object")
	}

	// upload presentation definition, verifier keys and proof program to ipfs
	//

	return &PolicyURISet{
		PresentationDefinition: "",
		ProofProgram:           "",
		ProvingKey:             "",
		VerificationKey:        "",
	}, nil
}

func (s Service) deployAndRegisterPolicyContract(ctx context.Context, uris PolicyURISet) (string, error) {

	// send tx: deploy policy with uris
	// send tx: register policy contract in registry

	return "", nil
}

// CreateSession houses the main service logic for session token storage.
// It accepts only requests from trusted parties that are indexing the blockchain state, validates the input, and
// stores a session entry.
func (s Service) CreateSession(ctx context.Context, request CreateSessionInput) (*StoredSession, error) {
	if !request.IsValid() {
		return nil, errors.Errorf("invalid create session request: %+v", request)
	}

	token, err := s.decryptJWE(ctx, request.SessionJWE, "kid")
	if err != nil {
		return nil, errors.Wrap(err, "could not decrypt session JWE")
	}

	return s.createSession(ctx, token)
}

func (s Service) decryptJWE(ctx context.Context, jweBytes []byte, kid string) (keyaccess.JWT, error) {

	key, err := s.keystore.GetKey(ctx, keystore.GetKeyRequest{ID: kid})
	if err != nil {
		return "", errors.Wrap(err, "getting key from keystore")
	}

	jwtBytes, err := jwe.Decrypt(jweBytes, jwe.WithKey(key.Type, key.Key))
	if err != nil {
		return "", errors.Wrap(err, "decrypting jwe")
	}

	return keyaccess.JWT(jwtBytes), nil
}

func (s Service) VerifySession(ctx context.Context, request VerifySessionInput) (*VerifySessionOutput, error) {

	_, session, err := util.ParseJWT(request.SessionToken)

	if err != nil {
		return &VerifySessionOutput{Verified: false, Reason: err.Error()}, nil
	}

	_, err = s.storageClient.GetSession(ctx, session.JwtID())

	if err != nil {
		return &VerifySessionOutput{Verified: true}, nil
	}

	tid := crypto.Keccak256Hash([]byte(session.JwtID()))
	exists, err := s.rpcService.CheckSession(ctx, rpc.CheckSessionParams{
		TokenID: tid,
		DID:     s.rpcService.Wallet.GetDIDHash(),
	})

	if err != nil {
		return &VerifySessionOutput{Verified: false, Reason: err.Error()}, nil
	}
	if !exists {
		return &VerifySessionOutput{Verified: false, Reason: "session id not found"}, nil
	}

	_, err = s.createSession(ctx, request.SessionToken)
	if err != nil {
		return &VerifySessionOutput{Verified: false, Reason: err.Error()}, nil
	}

	return &VerifySessionOutput{Verified: true}, nil
}

func (s Service) createSession(ctx context.Context, token keyaccess.JWT) (*StoredSession, error) {
	signature, session, err := util.ParseJWT(token)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse session token")
	}

	kid := signature.ProtectedHeaders().KeyID()
	if kid == "" {
		return nil, errors.Errorf("missing kid in header of session<%s>", session.JwtID())
	}

	// verify the token with the did by first resolving the did and getting the public key and next verifying the token
	if err = didint.VerifyTokenFromDID(ctx, s.resolver, session.Issuer(), kid, token); err != nil {
		return nil, errors.Wrapf(err, "verifying token from did<%s> with kid<%s>", session.Issuer(), kid)
	}

	storedSession := StoredSession{
		ID:         session.JwtID(),
		Audience:   session.Audience(),
		SessionJWT: token,
		Issuer:     session.Issuer(),
		Subject:    session.Subject(),
		CreatedAt:  session.IssuedAt(),
		Revoked:    false,
		Expired:    false,
	}

	if s.storageClient.InsertSession(ctx, storedSession) != nil {
		return nil, errors.Wrap(err, "storing session token")
	}

	return &storedSession, nil

}
