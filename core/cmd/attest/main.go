package attest

import (
	"crypto/sha256"
	"fmt"
)

import (
	"github.com/iden3/go-iden3-crypto/babyjub"
)

func main() {
	// generate babyJubjub private key randomly
	babyJubjubPrivKey := babyjub.NewRandPrivKey()
	// generate public key from private key
	babyJubjubPubKey := babyJubjubPrivKey.Public()

	hash := sha256.Sum256([]byte(24))

	// print public key
	fmt.Println(babyJubjubPubKey)
}
