package config

import (
	"strings"

	"github.com/fapiper/onchain-access-control/core/service/framework"
)

const (
	ServiceName    = "onchain-access-control"
	ServiceVersion = "0.0.3"
	APIVersion     = "v1"
)

var (
	si = &serviceInfo{
		name: ServiceName,
		description: "The Self Sovereign Identity Service is a RESTful web service that facilitates all things relating" +
			" to DIDs, VCs, and related standards-based interactions.",
		version:      ServiceVersion,
		apiVersion:   APIVersion,
		servicePaths: make(map[framework.Type]string),
	}
)

// serviceInfo is intended to be a singleton object for static service info.
// WARNING: it is **NOT** currently thread safe.
type serviceInfo struct {
	name          string
	description   string
	version       string
	apiBase       string
	statusBaseURL string
	fileStoreBase string
	apiVersion    string
	servicePaths  map[framework.Type]string
}

func Name() string {
	return si.name
}

func Description() string {
	return si.description
}

func (si *serviceInfo) Version() string {
	return si.version
}

func SetAPIBase(url string) {
	if strings.LastIndexAny(url, "/") == len(url)-1 {
		url = url[:len(url)-1]
	}
	si.apiBase = url
}

func GetAPIBase() string {
	return si.apiBase
}

func SetStatusBase(url string) {
	if strings.LastIndexAny(url, "/") == len(url)-1 {
		url = url[:len(url)-1]
	}
	si.statusBaseURL = url
}

func GetStatusBase() string {
	return si.statusBaseURL
}

func SetServicePath(service framework.Type, path string) {
	// normalize path
	if strings.IndexAny(path, "/") == 0 {
		path = path[1:]
	}
	si.servicePaths[service] = strings.Join([]string{si.apiBase, APIVersion, path}, "/")
}

func GetServicePath(service framework.Type) string {
	return si.servicePaths[service]
}

func SetFileStoreBase(path string) {
	pathLen := len(path)
	if pathLen > 1 {
		if strings.IndexAny(path, "/") == 0 {
			path = path[1:]
		}

		if strings.LastIndexAny(path, "/") == pathLen-1 {
			path = path[:pathLen-1]
		}
	}
	si.fileStoreBase = path
}

func GetFileStoreBase() string {
	return si.fileStoreBase
}
