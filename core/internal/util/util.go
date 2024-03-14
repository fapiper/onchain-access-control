package util

import (
	"reflect"
	"strings"

	didsdk "github.com/TBD54566975/ssi-sdk/did"
	"github.com/pkg/errors"
)

// IsStructPtr checks if the given object is a pointer to a struct
func IsStructPtr(obj any) bool {
	if obj == nil {
		return false
	}
	// make sure out is a ptr to a struct
	outVal := reflect.ValueOf(obj)
	if outVal.Kind() != reflect.Ptr {
		return false
	}

	// dereference the pointer
	outValDeref := outVal.Elem()
	if outValDeref.Kind() != reflect.Struct {
		return false
	}
	return true
}

// FromPointer returns the value of a pointer, or the zero value of the pointer's type if the pointer is nil.
func FromPointer[T comparable](s *T) T {
	if s == nil {
		return reflect.Zero(reflect.TypeOf(s).Elem()).Interface().(T)
	}
	return *s
}

func IsEmpty[T any](s *T) bool {
	return s == nil || any(*s) == reflect.Zero(reflect.TypeOf(s).Elem()).Interface()
}

func ToPointer[T any](s T) *T {
	return &s
}

func ToPointerSlice[T any](s []T) []*T {
	result := make([]*T, len(s))
	for i, v := range s {
		c := v
		result[i] = &c
	}
	return result
}

func FromPointerSlice[T any](s []*T) []T {
	result := make([]T, len(s))
	for i, v := range s {
		c := v
		result[i] = *c
	}
	return result
}

// GetMethodForDID gets a DID method from a did, the second part of the did (e.g. did:test:abcd, the method is 'test')
func GetMethodForDID(did string) (didsdk.Method, error) {
	split := strings.Split(did, ":")
	if len(split) < 3 {
		return "", errors.New("malformed did: did has fewer than three parts")
	}
	if split[0] != "did" {
		return "", errors.New("malformed did: did must start with `did`")
	}
	return didsdk.Method(split[1]), nil
}

// SanitizeLog prevents certain classes of injection attacks before logging
// https://codeql.github.com/codeql-query-help/go/go-log-injection/
func SanitizeLog(log string) string {
	escapedLog := strings.ReplaceAll(log, "\n", "")
	return strings.ReplaceAll(escapedLog, "\r", "")
}

// Is2xxResponse returns true if the given status code is a 2xx response
func Is2xxResponse(statusCode int) bool {
	return statusCode/100 == 2
}
