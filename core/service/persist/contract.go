package persist

import (
	"database/sql/driver"
	"encoding/json"
	"github.com/ethereum/go-ethereum/common"
	"strings"
)

// ZeroAddress is the all-zero Ethereum address
const ZeroAddress Address = "0x0000000000000000000000000000000000000000"

// Address represents an Ethereum address
type Address string

func (a Address) String() string {
	return normalizeAddress(strings.ToLower(string(a)))
}

// Address returns the ethereum address byte array
func (a Address) Address() common.Address {
	return common.HexToAddress(a.String())
}

// Value implements the database/sql/driver Valuer interface for the address type
func (a Address) Value() (driver.Value, error) {
	return a.String(), nil
}

// MarshalJSON implements the json.Marshaller interface for the address type
func (a Address) MarshalJSON() ([]byte, error) {
	return json.Marshal(a.String())
}

// UnmarshalJSON implements the json.Unmarshaller interface for the address type
func (a *Address) UnmarshalJSON(b []byte) error {
	var s string
	if err := json.Unmarshal(b, &s); err != nil {
		return err
	}
	*a = Address(normalizeAddress(strings.ToLower(s)))
	return nil
}

func normalizeAddress(address string) string {
	withoutPrefix := strings.TrimPrefix(address, "0x")
	if len(withoutPrefix) < 40 {
		return ""
	}
	return "0x" + withoutPrefix[len(withoutPrefix)-40:]
}
