package middleware

import (
	"github.com/fapiper/onchain-access-control/pkg/testutil"
	"github.com/stretchr/testify/require"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestAuthMiddleware(t *testing.T) {

	// USE_AUTH_TOKEN to true
	t.Setenv("USE_AUTH_TOKEN", "true")

	authService, err := testutil.CreateTestAuthService(t)
	require.NoError(t, err)
	require.NotEmpty(t, authService)

	// Create a new gin engine
	r := gin.Default()

	// Add the AuthMiddleware to the gin engine
	r.Use(AuthMiddleware(authService))

	// Add a test route
	r.GET("/test", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	// Create a request with the correct Authorization header
	req, _ := http.NewRequest(http.MethodGet, "/test", nil)
	req.Header.Add("Authorization", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c")

	// Create a response recorder
	w := httptest.NewRecorder()

	// Serve the request
	r.ServeHTTP(w, req)

	// Assert that the status code is 200 OK
	assert.Equal(t, http.StatusOK, w.Code)

	// Create a request with an incorrect Authorization header
	req, _ = http.NewRequest(http.MethodGet, "/test", nil)
	req.Header.Add("Authorization", "Bearer nonsense")

	// Reset the response recorder
	w = httptest.NewRecorder()

	// Serve the request
	r.ServeHTTP(w, req)

	// Assert that the status code is 401 Unauthorized
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestNoAuthMiddleware(t *testing.T) {

	// USE_AUTH_TOKEN is empty so things just work
	t.Setenv("USE_AUTH_TOKEN", "false")

	authService, err := testutil.CreateTestAuthService(t)
	require.NoError(t, err)
	require.NotEmpty(t, authService)

	// Create a new gin engine
	r := gin.Default()

	// Add the AuthMiddleware to the gin engine
	r.Use(AuthMiddleware(authService))

	// Add a test route
	r.GET("/test", func(c *gin.Context) {
		c.String(http.StatusOK, "OK")
	})

	// Create a request with the correct Authorization header
	req, _ := http.NewRequest(http.MethodGet, "/test", nil)

	// Create a response recorder
	w := httptest.NewRecorder()

	// Serve the request
	r.ServeHTTP(w, req)

	// Assert that the status code is 200 OK
	assert.Equal(t, http.StatusOK, w.Code)
}
