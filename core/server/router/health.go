package router

import (
	"net/http"

	"github.com/gin-gonic/gin"

	framework "github.com/fapiper/onchain-access-control/core/server/framework"
)

type GetHealthCheckResponse struct {
	// Status is always equal to `OK`.
	Status string `json:"status"`
}

const (
	HealthOK string = "OK"
)

// Health godoc
//
//	@Summary		Service health check
//	@Description	Health is a simple handler that always responds with a 200 OK
//	@Tags			ServiceInfo
//	@Accept			json
//	@Produce		json
//	@Success		200	{object}	GetHealthCheckResponse
//	@Router			/health [get]
func Health(c *gin.Context) {
	status := GetHealthCheckResponse{Status: HealthOK}
	framework.Respond(c, status, http.StatusOK)
}
