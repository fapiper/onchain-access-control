package auth

import (
	"context"
	"encoding/json"
	sdkutil "github.com/TBD54566975/ssi-sdk/util"
	"github.com/fapiper/onchain-access-control/core/internal/encryption"
	"github.com/fapiper/onchain-access-control/core/storage"
	"github.com/pkg/errors"
)

type Roles struct {
	Roles         []Role
	NextPageToken string
}

type Role struct {
	// Id of the role that identifies it within the context.
	Id string `json:"id"`
	// Context of the role.
	Context string `json:"context"`
	// Context of the role.
	Identifier string `json:"identifier"`
}

func (r *Role) IsValid() bool {
	return r.Id != "" && r.Context != ""
}

const (
	namespace = "auth"
)

type Storage struct {
	db        storage.ServiceStorage
	tx        storage.Tx
	encrypter encryption.Encrypter
	decrypter encryption.Decrypter
}

func NewAuthStorage(db storage.ServiceStorage, e encryption.Encrypter, d encryption.Decrypter, writer storage.Tx) (*Storage, error) {
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

func (s *Storage) InsertRole(ctx context.Context, role Role) error {
	if !role.IsValid() {
		return sdkutil.LoggingNewError("could not store role")
	}
	data, err := json.Marshal(role)
	if err != nil {
		return errors.Wrap(err, "marshalling role")
	}

	return s.db.Write(ctx, namespace, role.Id, data)
}

func (s *Storage) GetRole(ctx context.Context, id string) (*Role, error) {
	if id == "" {
		return nil, errors.New("cannot fetch issuance template without an ID")
	}
	data, err := s.db.Read(ctx, namespace, id)
	if err != nil {
		return nil, errors.Wrap(err, "reading from db")
	}
	if len(data) == 0 {
		return nil, errors.Errorf("role not found with id: %s", id)
	}
	var r Role
	if err = json.Unmarshal(data, &r); err != nil {
		return nil, errors.Wrap(err, "unmarshalling role")
	}
	return &r, nil
}
