package accesscontrol

import (
	"context"
	"encoding/json"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/ethereum/go-ethereum/common"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/service/persist"
	"github.com/fapiper/onchain-access-control/core/storage"
	"time"
)

type StoredAccessContext struct {
	ID      common.Hash     `json:"id"`
	Address persist.Address `json:"address,omitempty"`
}

type StoredSession struct {
	ID         string        `json:"id"`
	SessionJWT keyaccess.JWT `json:"token,omitempty"`
	Issuer     string        `json:"issuer"`
	Audience   []string      `json:"audience"`
	Subject    string        `json:"subject"`
	CreatedAt  time.Time     `json:"createdAt"`
	Revoked    bool          `json:"revoked"`
	RevokedAt  string        `json:"revokedAt"`
	Expired    bool          `json:"expired"`
	ExpiresAt  time.Time     `json:"expiresAt"`
}

const (
	namespace = "accesscontrol"
)

type Storage struct {
	db        storage.ServiceStorage
	tx        storage.Tx
	encrypter encryption.Encrypter
	decrypter encryption.Decrypter
}

func NewAccessControlStorage(db storage.ServiceStorage, e encryption.Encrypter, d encryption.Decrypter, writer storage.Tx) (*Storage, error) {

	s := &Storage{
		db:        db,
		encrypter: e,
		decrypter: d,
		tx:        db,
	}
	if writer != nil {
		s.tx = writer
	}
	if s.encrypter == nil {
		s.encrypter = encryption.NoopEncrypter
	}
	if s.decrypter == nil {
		s.decrypter = encryption.NoopDecrypter
	}

	return s, nil
}

func (s *Storage) InsertAccessContext(ctx context.Context, access StoredAccessContext) error {
	id := access.ID.String()
	if id == "" {
		return sdkutil.LoggingNewError("could not store access context without an ID")
	}

	accessBytes, err := json.Marshal(access)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "deserializing access context")
	}

	return s.tx.Write(ctx, namespace, id, accessBytes)
}

func (s *Storage) GetAccessContext(ctx context.Context, id string) (*StoredAccessContext, error) {
	storedAccessBytes, err := s.db.Read(ctx, namespace, id)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "getting access context details for access context <%s>", id)
	}
	if len(storedAccessBytes) == 0 {
		return nil, sdkutil.LoggingNewErrorf("could not find access context details for access context <%s>", id)
	}

	var stored StoredAccessContext
	if err = json.Unmarshal(storedAccessBytes, &stored); err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "unmarshalling stored access context: %s", id)
	}
	return &stored, nil
}

func (s *Storage) CheckAccessContextExists(ctx context.Context, id string) (bool, error) {
	storedAccessBytes, err := s.db.Read(ctx, namespace, id)
	if err != nil {
		return false, sdkutil.LoggingErrorMsgf(err, "getting access context details for access context <%s>", id)
	}
	return len(storedAccessBytes) > 0, nil
}

func (s *Storage) InsertSession(ctx context.Context, session StoredSession) error {
	id := session.ID
	if id == "" {
		return sdkutil.LoggingNewError("could not store session without an ID")
	}

	sessionBytes, err := json.Marshal(session)
	if err != nil {
		return sdkutil.LoggingErrorMsg(err, "deserializing session from base58")
	}

	// encrypt session before storing
	encryptedSession, err := s.encrypter.Encrypt(ctx, sessionBytes, nil)
	if err != nil {
		return sdkutil.LoggingErrorMsgf(err, "could not encrypt session: %s", session.ID)
	}

	return s.tx.Write(ctx, namespace, id, encryptedSession)
}

func (s *Storage) GetSession(ctx context.Context, id string) (*StoredSession, error) {
	storedSessionBytes, err := s.db.Read(ctx, namespace, id)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "getting session details for session <%s>", id)
	}
	if len(storedSessionBytes) == 0 {
		return nil, sdkutil.LoggingNewErrorf("could not find session details for session <%s>", id)
	}

	// decrypt session before unmarshalling
	decryptedSession, err := s.decrypter.Decrypt(ctx, storedSessionBytes, nil)
	if err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "could not decrypt session: %s", id)
	}

	var stored StoredSession
	if err = json.Unmarshal(decryptedSession, &stored); err != nil {
		return nil, sdkutil.LoggingErrorMsgf(err, "unmarshalling stored session: %s", id)
	}
	return &stored, nil
}
