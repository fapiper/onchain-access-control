package util

import (
	"context"
	"strings"

	"github.com/pkg/errors"
	"github.com/sourcegraph/conc/pool"
)

// FieldError is used to indicate an error with a field in a request payload.
type FieldError struct {
	Field string `json:"field"`
	Error string `json:"error"`
}

// ErrorResponse is the structure of response error payloads sent back to the requester
// when validation of a request payload fails.
type ErrorResponse struct {
	Error  string `json:"error"`
	Fields string `json:"fields,omitempty"`
}

// SafeError is used to pass an error during the request through the server with
// web specific context. 'Safe' here means that the error messages do not include
// any sensitive information and can be sent straight back to the requester
type SafeError struct {
	Err        error
	StatusCode int
	Fields     []FieldError
}

// SafeError implements the `error` interface. It uses the default message of the
// wrapped error. This is what will be shown in a server's logs
func (err *SafeError) Error() string {
	return err.Err.Error()
}

// FieldErrors returns a string containing all field errors.
func (err *SafeError) FieldErrors() string {
	if len(err.Fields) == 0 {
		return ""
	}
	fieldErrs := make([]string, 0, len(err.Fields))
	for _, field := range err.Fields {
		fieldErrs = append(fieldErrs, field.Error)
	}
	return strings.Join(fieldErrs, ", ")
}

// ErrHTTP represents an error returned from an HTTP request
type ErrHTTP struct {
	Err        error
	StatusCode int
	URL        string
}

func (h ErrHTTP) Error() string {
	return errors.Errorf("HTTP Error Status - %d | URL - %s | Error: %s", h.StatusCode, h.URL, h.Err).Error()
}

func (h ErrHTTP) Unwrap() error {
	return h.Err
}

// shutdown is a type used to help with graceful shutdown of a server.
type shutdown struct {
	Message string
}

// shutdown implements the Error interface
func (s *shutdown) Error() string {
	return s.Message
}

// NewShutdownError returns an error that causes the framework to signal.
// a graceful shutdown
func NewShutdownError(message string) error {
	return &shutdown{message}
}

// IsShutdown checks to see if the shutdown error is contained in
// the specified error value.
func IsShutdown(err error) bool {
	var shutdownErr *shutdown
	return errors.As(errors.Cause(err), &shutdownErr)
}

func FirstNonErrorWithValue[T any](ctx context.Context, autoCancel bool, returnOnError func(error) bool, runs ...func(context.Context) (T, error)) (T, error) {

	if len(runs) == 0 {
		return *new(T), nil
	}

	if returnOnError == nil {
		returnOnError = func(error) bool { return false }
	}

	var cancel context.CancelFunc
	if autoCancel {
		ctx, cancel = context.WithCancel(ctx)
		defer cancel()
	}

	wp := pool.New().WithMaxGoroutines(len(runs)).WithErrors()

	result := make(chan T)
	errChan := make(chan error)
	for _, run := range runs {
		run := run
		wp.Go(func() error {
			val, err := run(ctx)
			if err != nil {
				if returnOnError(err) {
					errChan <- err
					return err
				}
				return err
			}
			result <- val
			return nil
		})
	}

	go func() {
		errChan <- wp.Wait()
	}()

	select {
	case val := <-result:
		return val, nil
	case err := <-errChan:
		return *new(T), err
	case <-ctx.Done():
		return *new(T), ctx.Err()
	}
}
