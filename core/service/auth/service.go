package auth

import (
	"context"
	"fmt"
	"github.com/TBD54566975/ssi-sdk/did/resolution"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
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
func (s Service) StartSession(ctx context.Context) (*jwt.Token, string, error) {
	tid := uuid.NewString()

	builder := jwt.NewBuilder().
		Audience([]string{s.rpcService.Wallet.GetDID()}).
		Subject(s.rpcService.Wallet.GetDID()).
		Issuer(s.rpcService.Wallet.GetDID()).
		JwtID(tid)

	token, err := builder.Build()

	signedToken, err := jwt.Sign(token, jwt.WithKey(jwa.ES256K, s.rpcService.Wallet.PrivateKey))
	if err != nil {
		return nil, "", errors.Wrap(err, "failed to sign token")
	}

	_, err = s.rpcService.StartSession(ctx, rpc.StartSessionParams{
		DID:        s.rpcService.Wallet.GetDIDHash(),
		TokenID:    crypto.Keccak256Hash([]byte(tid)),
		SessionJWE: crypto.Keccak256Hash(signedToken).Bytes(),
	})

	if err != nil {
		return nil, "", errors.Wrap(err, "unable to start session transaction")
	}

	return &token, string(signedToken), nil
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

// GrantRole verifies a policy and assign the role.
func (s Service) GrantRole(ctx context.Context, input GrantRoleInput) (*Role, error) {
	if !input.IsValid() {
		return nil, errors.Errorf("invalid grant role input: %+v", input)
	}

	role, err := persist.ParseRoleFromIdentifierString(input.RoleID)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse role from identifier string")
	}

	policy, err := persist.ParsePolicyFromIdentifierString(input.PolicyID)
	if err != nil {
		return nil, errors.Wrap(err, "could not parse policy from identifier string")
	}

	params := s.buildGrantRoleParams(role, policy, input.Proof, input.Inputs)
	logrus.Infof("GrantRoleParams: %s", params)

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

func (s Service) buildGrantRoleParams(role *persist.Role, policy *persist.Policy, proof contracts.IPolicyVerifierProof, inputs [20]*big.Int) rpc.GrantRoleParams {
	roleIdentifier := persist.NewRoleIdentifier(role.ContextID, role.RoleID)
	policyIdentifier := persist.NewPolicyIdentifier(policy.ContextID, policy.PolicyID)

	return rpc.GrantRoleParams{
		RoleIdentifier:   roleIdentifier,                   // input.RoleId
		DID:              s.rpcService.Wallet.GetDIDHash(), // DID
		PolicyIdentifier: policyIdentifier,
		Proof:            proof,
		Inputs:           inputs,
	}
}
