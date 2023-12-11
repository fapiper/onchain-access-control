package main

import (
	"github.com/fapiper/onchain-access-control/pkg/consumer"
	"github.com/fapiper/onchain-access-control/pkg/owner"
)

func main() {
	owner.Init()
	consumer.Init()
}
