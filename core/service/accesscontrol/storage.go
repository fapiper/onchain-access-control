package access

import (
	"context"
	"encoding/json"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/storage"
	"time"
)

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
