package module_supplier_1

import (
	"github.com/fapiper/onchain-access-control/pkg/issuer"
	"github.com/fapiper/onchain-access-control/pkg/owner"
)

func main() {
	owner.Init()
	issuer.Init()
}
