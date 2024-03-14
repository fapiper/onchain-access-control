package auth

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/did/resolution"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/contracts"
	didint "github.com/fapiper/onchain-access-control/core/internal/did"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/internal/util"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/keystore"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/fapiper/onchain-access-control/core/storage"
	"github.com/google/uuid"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/lestrrat-go/jwx/v2/jwa"
	"github.com/lestrrat-go/jwx/v2/jwe"
	"github.com/lestrrat-go/jwx/v2/jwt"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"math/big"
)

type ServiceFactory func(storage.Tx) (*Service, error)
type Service struct {
	storageClient *Storage
	ipfsClient    *shell.Shell
	rpcService    *rpc.Service
	keystore      *keystore.Service
	resolver      resolution.Resolver
}

func (s Service) Type() framework.Type {
	return framework.Auth
}

func (s Service) Status() framework.Status {
	e := sdkutil.NewAppendError()
	if s.storageClient == nil {
		e.AppendString("no storage configured")
	}
	if s.ipfsClient == nil {
		e.AppendString("no ipfs client configured")
	}
	if s.rpcService == nil {
		e.AppendString("no rpc service configured")
	}
	if !e.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("auth service is not ready: %s", e.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewAuthService(config config.AuthServiceConfig, s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service, rpcService *rpc.Service, ipfsClient *shell.Shell) (*Service, error) {
	encrypter, decrypter, err := keystore.NewServiceEncryption(s, config.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating new encryption")
	}

	factory := NewAuthServiceFactory(s, r, k, encrypter, decrypter, rpcService, ipfsClient)
	return factory(s)
}

func NewAuthServiceFactory(s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service, encrypter encryption.Encrypter, decrypter encryption.Decrypter, rpcService *rpc.Service, ipfsClient *shell.Shell) ServiceFactory {
	return func(tx storage.Tx) (*Service, error) {
		// Next, instantiate the key storage
		sc, err := NewAuthStorage(s, encrypter, decrypter, tx)

		if err != nil {
			return nil, sdkutil.LoggingErrorMsg(err, "instantiating storage for the auth service")
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

// StartSession starts a session by registering the session token on-chain.
func (s Service) StartSession(ctx context.Context, request StartSessionInput) (*jwt.Token, *[]byte, error) {
	if !request.IsValid() {
		return nil, nil, errors.Errorf("invalid create session request: %+v", request)
	}
	tid := uuid.NewString()

	builder := jwt.NewBuilder().
		Audience(request.Audience).
		Subject(s.rpcService.Wallet.GetDID()).
		Issuer(s.rpcService.Wallet.GetDID()).
		JwtID(tid)

	token, err := builder.Build()

	signedToken, err := jwt.Sign(token, jwt.WithKey(jwa.ES256K, s.rpcService.Wallet.PrivateKey))
	if err != nil {
		return nil, nil, errors.Wrap(err, "failed to sign token")
	}

	_, err = s.rpcService.StartSession(ctx, rpc.StartSessionParams{
		DID:        s.rpcService.Wallet.GetDIDHash(),
		TokenID:    crypto.Keccak256Hash([]byte(tid)),
		SessionJWE: crypto.Keccak256Hash(signedToken).Bytes(),
	})

	if err != nil {
		return nil, nil, errors.Wrap(err, "unable to start session transaction")
	}

	//stored := Role{Id: role.RoleID, Context: role.ContextID, Identifier: params.RoleIdentifier.String()}
	//
	//if err = s.storageClient.InsertRole(ctx, stored); err != nil {
	//	return nil, errors.Wrap(err, "could not store role for user")
	//}

	return &token, &signedToken, nil
}

func (s Service) encryptJWE(ctx context.Context, signedToken []byte, audience string) ([]byte, error) {
	did, err := s.resolver.Resolve(ctx, audience)
	if err != nil {
		return nil, errors.Wrap(err, "resolve doc for did")
	}

	if len(did.Document.VerificationMethod) < 1 {
		return nil, errors.Wrap(err, "no verification method for did")
	}
	verificationMethod := did.Document.VerificationMethod[0]

	return jwe.Encrypt(signedToken, jwe.WithKey(verificationMethod.Type, verificationMethod.PublicKeyJWK))

}

// CreateSession houses the main service logic for session token storage.
// It accepts only requests from trusted parties that are indexing the blockchain state, validates the input, and
// stores a session entry.
func (s Service) CreateSession(ctx context.Context, request CreateSessionInput) (*StoredSession, error) {
	if !request.IsValid() {
		return nil, errors.Errorf("invalid create session request: %+v", request)
	}

	sessionJWT, err := s.decryptJWE(ctx, request.SessionJWE, "kid")
	if err != nil {
		return nil, errors.Wrap(err, "could not decrypt session JWE")
	}

	signature, session, err := util.ParseJWT(sessionJWT)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse session JWT")
	}

	kid := signature.ProtectedHeaders().KeyID()
	if kid == "" {
		return nil, errors.Errorf("missing kid in header of session<%s>", session.JwtID())
	}

	// verify the token with the did by first resolving the did and getting the public key and next verifying the token
	if err = didint.VerifyTokenFromDID(ctx, s.resolver, session.Issuer(), kid, sessionJWT); err != nil {
		return nil, errors.Wrapf(err, "verifying token from did<%s> with kid<%s>", session.Issuer(), kid)
	}

	// TODO verify nonce

	storedSession := StoredSession{
		ID:         session.JwtID(),
		Audience:   session.Audience(),
		SessionJWT: sessionJWT, // TODO only store encrypted token
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
	logrus.Debugf("verifying session: %+v", request)

	_, session, err := util.ParseJWT(request.SessionJWT)
	if err != nil {
		return &VerifySessionOutput{Verified: false, Reason: err.Error()}, nil
	}

	_, err = s.storageClient.GetSession(ctx, session.JwtID())
	if err != nil {
		return &VerifySessionOutput{Verified: false, Reason: err.Error()}, nil
	}
	// TODO
	//	err := s.verifier.VerifyJWTSession(ctx, session)
	//	if err != nil {
	//		return &VerifySessionResponse{Verified: false, Reason: err.Error()}, nil
	//	}

	return &VerifySessionOutput{Verified: true}, nil
}

// GrantRole verifies a policy and assign the role.
func (s Service) GrantRole(ctx context.Context, input GrantRoleInput) (*Role, error) {
	if !input.IsValid() {
		return nil, errors.Errorf("invalid grant role input: %+v", input)
	}

	role, err := persist.ParseRoleFromIdentifierString(input.RoleID)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse role from param")
	}

	params := s.buildGrantRoleParams(role, input.Proof, input.Inputs)

	_, err = s.rpcService.GrantRole(ctx, params)
	if err != nil {
		return nil, errors.Wrap(err, "unable to execute grant role transaction")
	}

	stored := Role{Id: role.RoleID, Context: role.ContextID, Identifier: params.RoleIdentifier.String()}

	if err = s.storageClient.InsertRole(ctx, stored); err != nil {
		return nil, errors.Wrap(err, "could not store role for user")
	}

	return &stored, nil
}

func (s Service) buildGrantRoleParams(role *persist.Role, proof contracts.IPolicyVerifierProof, inputs [20]*big.Int) rpc.GrantRoleParams {
	roleIdentifier := persist.NewRoleIdentifier(role.ContextID, role.RoleID)
	policyIdentifier := persist.NewPolicyIdentifier(roleIdentifier.ContextID, roleIdentifier.RoleID)

	return rpc.GrantRoleParams{
		RoleIdentifier:   roleIdentifier,                   // input.RoleId
		DID:              s.rpcService.Wallet.GetDIDHash(), // DID
		PolicyIdentifier: policyIdentifier,
		Proof:            proof,
		Inputs:           inputs,
	}
}
