package auth

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/did/resolution"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/fapiper/onchain-access-control/core/config"
	didint "github.com/fapiper/onchain-access-control/core/internal/did"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/internal/util"
	"github.com/fapiper/onchain-access-control/core/service/framework"
	"github.com/fapiper/onchain-access-control/core/service/keystore"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/fapiper/onchain-access-control/core/service/rpc"
	"github.com/fapiper/onchain-access-control/core/storage"
	"github.com/fapiper/onchain-access-control/core/tx"
	shell "github.com/ipfs/go-ipfs-api"
	"github.com/lestrrat-go/jwx/v2/jwe"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
)

type ServiceFactory func(storage.Tx) (*Service, error)
type Service struct {
	storageClient *Storage
	ipfsClient    *shell.Shell
	ethClient     *ethclient.Client
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
	if s.ethClient == nil {
		e.AppendString("no eth client configured")
	}
	if !e.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("auth service is not ready: %s", e.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewAuthService(config config.AuthServiceConfig, s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service, ethClient *ethclient.Client, ipfsClient *shell.Shell) (*Service, error) {
	encrypter, decrypter, err := keystore.NewServiceEncryption(s, config.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating new encryption")
	}

	factory := NewAuthServiceFactory(s, r, k, encrypter, decrypter, ethClient, ipfsClient)
	return factory(s)
}

func NewAuthServiceFactory(s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service, encrypter encryption.Encrypter, decrypter encryption.Decrypter, ethClient *ethclient.Client, ipfsClient *shell.Shell) ServiceFactory {
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
			ipfsClient:    ipfsClient,
			ethClient:     ethClient,
		}
		if !service.Status().IsReady() {
			return nil, errors.New(service.Status().Message)
		}
		return &service, nil
	}
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
func (s Service) GrantRole(ctx context.Context, input GrantRoleInput, password string, chainID uint64) (*Role, error) {
	if !input.IsValid() {
		return nil, errors.Errorf("invalid grant role input: %+v", input)
	}

	txOpts := tx.SendTxArgs{}.ToTransactOpts("key", password, chainID)

	params := rpc.GrantRoleParams{
		RoleId:        [32]byte{}, // input.RoleId
		DID:           [32]byte{}, // DID
		PolicyId:      [32]byte{},
		PolicyContext: [32]byte{},
	}

	_, err := rpc.GrantRole(ctx, txOpts, s.ethClient, persist.Address(input.RoleContext), params)
	if err != nil {
		return nil, errors.Wrap(err, "unable to execute grant role transaction")
	}

	stored := Role{Id: input.RoleId, Context: input.RoleContext}

	err = s.storageClient.InsertRole(ctx, stored)
	if err != nil {
		return nil, errors.Wrap(err, "could not store role for user")
	}

	return &stored, nil
}
