package middleware

import (
	"github.com/fapiper/onchain-access-control/core/config"
	"github.com/fapiper/onchain-access-control/core/server/framework"
	"os"
	"syscall"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"

	"go.opentelemetry.io/otel/trace"
)

// Errors handles errors coming out of the call stack. It detects safe application
// errors (aka SafeError) that are used to respond to the requester in a
// normalized way. Unexpected errors (status >= 500) are logged.
func Errors(shutdown chan os.Signal) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		tracer := trace.SpanFromContext(c).TracerProvider().Tracer(config.ServiceName)
		_, span := tracer.Start(c, "service.middleware.errors")
		defer span.End()

		errors := c.Errors.ByType(gin.ErrorTypeAny)
		if len(errors) > 0 {
			// check if there's a shutdown-worthy error
			for _, e := range errors {
				if framework.IsShutdown(e.Err) {
					logrus.WithError(e).Errorf("%s : SHUTDOWN ERROR", span.SpanContext().TraceID().String())
					shutdown <- syscall.SIGTERM
					return
				}
			}

			// otherwise just log the errors and return to the caller
			logrus.Errorf("%s : ERROR : %v", span.SpanContext().TraceID().String(), errors)
			c.JSON(-1, errors)
		}
	}
}
