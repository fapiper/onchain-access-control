package auth

import (
	_ "embed"
)

//func TestCreateSession(t *testing.T) {
//	authService, err := testutil.CreateTestAuthService(t)
//	assert.NoError(t, err)
//	assert.NotEmpty(t, authService)
//
//	// create a session
//	createSessionRequest := CreateSessionRequest{
//		SessionJWE: []byte(nil),
//	}
//
//	created, err := authService.CreateSession(context.Background(), createSessionRequest)
//	assert.NoError(t, err)
//	assert.NotEmpty(t, created)
//}
