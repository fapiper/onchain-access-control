package access

import (
	"github.com/fapiper/onchain-access-control/pkg/storage"
)

const (
	namespace = "access"
)

type Storage struct {
	db storage.ServiceStorage
	tx storage.Tx
}

func NewAccessStorage(db storage.ServiceStorage) (*Storage, error) {
	s := &Storage{
		db: db,
		tx: db,
	}
	return s, nil
}
