package main

import (
	"github.com/fapiper/onchain-access-control/core/consumer"
	"github.com/fapiper/onchain-access-control/core/owner"
)

func main() {
	owner.Init()
	consumer.Init()
}
