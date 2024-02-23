package main

import (
	"github.com/fapiper/onchain-access-control/core/resourceuser"
	"github.com/sirupsen/logrus"
	"net/http"
)

func main() {
	resourceuser.Init()

	logrus.Info("Running")
	if err := http.ListenAndServe(":4000", nil); err != nil {
		logrus.Fatalf("main: error: %s", err.Error())
	}
}
