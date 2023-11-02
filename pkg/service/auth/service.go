package auth

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/did/resolution"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/config"
	didint "github.com/fapiper/onchain-access-control/internal/did"
	"github.com/fapiper/onchain-access-control/internal/encryption"
	"github.com/fapiper/onchain-access-control/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/internal/util"
	"github.com/fapiper/onchain-access-control/pkg/service/framework"
	"github.com/fapiper/onchain-access-control/pkg/service/keystore"
	"github.com/fapiper/onchain-access-control/pkg/storage"
	"github.com/lestrrat-go/jwx/v2/jwe"
	"github.com/pkg/errors"
)

type ServiceFactory func(storage.Tx) (*Service, error)
type Service struct {
	storage  *Storage
	keystore *keystore.Service
	resolver resolution.Resolver
}

func (s Service) Type() framework.Type {
	return framework.Auth
}

func (s Service) Status() framework.Status {
	ae := sdkutil.NewAppendError()
	if s.storage == nil {
		ae.AppendString("no storage configured")
	}
	if !ae.IsEmpty() {
		return framework.Status{
			Status:  framework.StatusNotReady,
			Message: fmt.Sprintf("auth service is not ready: %s", ae.Error().Error()),
		}
	}
	return framework.Status{Status: framework.StatusReady}
}

func NewAuthService(config config.KeyStoreServiceConfig, s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service) (*Service, error) {
	encrypter, decrypter, err := keystore.NewServiceEncryption(s, config.EncryptionConfig, keystore.ServiceKeyEncryptionKey)
	if err != nil {
		return nil, errors.Wrap(err, "creating new encryption")
	}

	factory := NewAuthServiceFactory(s, r, k, encrypter, decrypter)
	return factory(s)
}

func NewAuthServiceFactory(s storage.ServiceStorage, r resolution.Resolver, k *keystore.Service, encrypter encryption.Encrypter, decrypter encryption.Decrypter) ServiceFactory {
	return func(tx storage.Tx) (*Service, error) {
		// Next, instantiate the key storage
		authStorage, err := NewAuthStorage(s, encrypter, decrypter, tx)

		if err != nil {
			return nil, sdkutil.LoggingErrorMsg(err, "instantiating storage for the auth service")
		}

		service := Service{
			storage:  authStorage,
			keystore: k,
			resolver: r,
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
func (s Service) CreateSession(ctx context.Context, request CreateSessionRequest) (*StoredSession, error) {
	if !request.IsValid() {
		return nil, errors.Errorf("invalid create session request: %+v", request)
	}

	sessionJWT, err := s.decryptJWE(ctx, request.SessionJWE, "<keyid>")
	if err != nil {
		return nil, errors.Wrap(err, "could not decrypt session JWE")
	}

	signature, session, err := util.ParseJWT(sessionJWT)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse session JWT")
	}

	issuerKID := signature.ProtectedHeaders().KeyID()
	if issuerKID == "" {
		return nil, errors.Errorf("missing kid in header of session<%s>", session.JwtID())
	}

	// verify the token with the did by first resolving the did and getting the public key and next verifying the token
	if err = didint.VerifyTokenFromDID(ctx, s.resolver, session.Issuer(), issuerKID, sessionJWT); err != nil {
		return nil, errors.Wrapf(err, "verifying token from did<%s> with kid<%s>", session.Issuer(), issuerKID)
	}

	// TODO verify nonce

	storedSession := StoredSession{
		ID:       session.JwtID(),
		Audience: session.Audience(),
	}

	if s.storage.StoreSession(ctx, storedSession) != nil {
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

func (s Service) VerifySession(ctx context.Context, request VerifySessionRequest) (*VerifySessionResponse, error) {
	logrus.Debugf("verifying session: %+v", request)

	_, session, err := util.ParseJWT(request.SessionJWT)
	if err != nil {
		return &VerifySessionResponse{Verified: false, Reason: err.Error()}, nil
	}

	_, err = s.storage.GetSession(ctx, session.JwtID())
	if err != nil {
		return &VerifySessionResponse{Verified: false, Reason: err.Error()}, nil
	}
	// TODO
	//	err := s.verifier.VerifyJWTSession(ctx, session)
	//	if err != nil {
	//		return &VerifySessionResponse{Verified: false, Reason: err.Error()}, nil
	//	}

	return &VerifySessionResponse{Verified: true}, nil
}
