package auth

import (
	"context"
	_ "embed"
	"github.com/fapiper/onchain-access-control/pkg/testutil"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestCreateSession(t *testing.T) {
	authService, err := testutil.CreateTestAuthService(t)
	assert.NoError(t, err)
	assert.NotEmpty(t, authService)

	// create a session
	createSessionRequest := CreateSessionRequest{
		SessionJWE: []byte(nil),
	}

	created, err := authService.CreateSession(context.Background(), createSessionRequest)
	assert.NoError(t, err)
	assert.NotEmpty(t, created)
}
