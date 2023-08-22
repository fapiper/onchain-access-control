package main

import (
	"github.com/TBD54566975/ssi-sdk/crypto"
	"github.com/TBD54566975/ssi-sdk/did/key"
	"github.com/TBD54566975/ssi-sdk/util"
	"github.com/gin-gonic/gin"
	"net/http"
)

func main() {
	engine := gin.Default()
	engine.GET("/", func(c *gin.Context) {
		_, didKey, err := key.GenerateDIDKey(crypto.SECP256k1)
		if err != nil {
			//log.Fatal(err, "failed to generate key")
		}

		didDoc, err := didKey.Expand()

		if err != nil {
			//log.Fatal(err, "failed to expand did:key")
		}

		dat, err := util.PrettyJSON(didDoc)

		if err != nil {
			//log.Fatal(err, "failed to expand did:key")
		}

		c.JSON(http.StatusOK, dat)

	})

	engine.Run(":3002")

	// Step 1: Create DID if not already created
	// Step 2: Register VC Schema if not already registered
	// Step 3: Listen to requests
}
