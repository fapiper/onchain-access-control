package middleware

import (
	"crypto/sha256"
	"encoding/hex"
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

func AuthMiddleware() gin.HandlerFunc {
	useAuthToken, _ := strconv.ParseBool(os.Getenv("USE_AUTH_TOKEN"))

	return func(c *gin.Context) {
		// If USE_AUTH_TOKEN is false or not set, skip the authentication
		if !useAuthToken {
			c.Next()
			return
		}

		token := c.GetHeader("Authorization")
		authToken := ""

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
