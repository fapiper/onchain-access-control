package middleware

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"github.com/fapiper/onchain-access-control/config"
	"github.com/sirupsen/logrus"
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

func AuthMiddleware() gin.HandlerFunc {
	useAuthToken, _ := strconv.ParseBool(os.Getenv("USE_AUTH_TOKEN"))

	return func(c *gin.Context) {
		token := c.GetHeader("Authorization")
		// TODO Retrieve `fileDidUrl` from token:
		// fileDidUrl := "did:pkh:0x1234?ref=static/test.csv"
		fileRefFromToken := "static/test.csv"
		// 1. check if `fileRefFromToken` matches requested file
		fileRefFromPath := fmt.Sprintf("%s%s", config.GetFileStoreBase(), c.Param(fileRefParamKey))

		logrus.Infof("fileRefFromToken: %s, fileRefFromPath: %s", fileRefFromToken, fileRefFromPath)

		// 2. check if token exists in db and isn't expired
		authToken := ""

		// If USE_AUTH_TOKEN is false or not set, skip the authentication
		if !useAuthToken {
			c.Next()
			return
		}

		// Remove "Bearer " from the token
		if len(token) > 7 && token[:7] == "Bearer " {
			token = token[7:]
		}

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
