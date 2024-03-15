package middleware

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/internal/keyaccess"
	"github.com/fapiper/onchain-access-control/core/service/accesscontrol"
	"net/http"
	"os"
	"strconv"

	"github.com/gin-gonic/gin"
)

/*
To use this middleware, you need to add it to your gin router in server.go:

// setUpEngine creates the gin engine and sets up the middleware based on config
func setUpEngine(cfg config.ServerConfig, shutdown chan os.Signal) *gin.Engine {
	gin.ForceConsoleColor()
	middlewares := gin.HandlersChain{
		gin.Recovery(),
		gin.Logger(),
		middleware.Errors(shutdown),
		middleware.AuthMiddleware(),
	}
*/

const (
	fileRefParamKey = "filepath"
)

type authHeader struct {
	Token string `header:"Authorization"`
}

func AuthMiddleware(accessControlService *accesscontrol.Service) gin.HandlerFunc {
	useAuthToken, _ := strconv.ParseBool(os.Getenv("USE_AUTH_TOKEN"))

	return func(c *gin.Context) {

		// If USE_AUTH_TOKEN is false or not set, skip the authentication
		if !useAuthToken {
			c.Next()
			return
		}

		header := authHeader{}

		if err := c.ShouldBindHeader(header); err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization is required"})
			c.Abort()
			return
		}

		// Remove "Bearer " from the token
		token := header.Token
		if len(header.Token) > 7 && header.Token[:7] == "Bearer " {
			token = header.Token[7:]
		}

		result, err := accessControlService.VerifySession(c, accesscontrol.VerifySessionInput{SessionJWT: keyaccess.JWT(token)})

		if !result.Verified || err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": result.Reason})
			c.Abort()
			return
		}

		// TODO Retrieve `fileDidUrl` from token:
		// fileDidUrl := "did:pkh:0x1234?ref=static/test.csv"
		fileRefFromToken := "static/test.txt"
		fileRefFromPath := fmt.Sprintf("%s%s", config.GetFileStoreBase(), c.Param(fileRefParamKey))

		// 1. check if `fileRefFromToken` matches requested file
		if fileRefFromToken != fileRefFromPath {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Session token invalid"})
			c.Abort()
			return
		}

		// 2. check if token exists in db and isn't expired
		authToken := ""

		// Generate SHA256 hash of the token from the header
		hash := sha256.Sum256([]byte(token))
		hashedToken := hex.EncodeToString(hash[:])

		// Check if the hashed token from the header matches the AUTH token
		if hashedToken != authToken {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization is required"})
			c.Abort()
			return
		}

		c.Next()
	}
}
