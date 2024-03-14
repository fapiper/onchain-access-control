package auth

import (
	"github.com/ethereum/go-ethereum/common/math"
	"github.com/fapiper/onchain-access-control/core/contracts"
	"math/big"
)

var Proof = contracts.IPolicyVerifierProof{
	A: contracts.PairingG1Point{
		X: math.MustParseBig256("0x207e9b1f9a9633d0a9086638aabee33c172ba94c713b3e04b4530cafd5fd042f"),
		Y: math.MustParseBig256("0x17af83f93b31de19741bf4a376d1caae08d6e517b2d772156cbe350681cd2e82"),
	},
	B: contracts.PairingG2Point{
		X: [2]*big.Int{
			math.MustParseBig256("0x1292827c3f09eea38778bd54da04415036b1e206eee4bd8877a8ab197ccfd5c4"),
			math.MustParseBig256("0x25e3c901e4f17dee4a743efefa33983e07734ce1695f787c4f7f94d9cd94726f"),
		},
		Y: [2]*big.Int{
			math.MustParseBig256("0x149aa0c72acda7ec484877b1582d74612def5025bbcd7fbfbfb80327ea8f4792"),
			math.MustParseBig256("0x1382e3e087ab8b4297d3214f390e6099874e09db2aa15cf33b53afb6f63f2ce7"),
		},
	},
	C: contracts.PairingG1Point{
		X: math.MustParseBig256("0x0fa1fef03502c56dafd34c9e08e2dc089a622667d77133ba380cab0c98c20598"),
		Y: math.MustParseBig256("0x044b495dafb8e35138cde24fa9749f4a91f99104f19770742e29b7dbf798382a"),
	},
}

var Inputs = [20]*big.Int{
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000000131c9a5"),
	math.MustParseBig256("0x196ad888b3d5184eec5967943eeb4d211aa41c0e68f9634cf5a14a91f9df206d"),
	math.MustParseBig256("0x24d0fafb29a809fa7a55a6aacc57f78d794721aca594d7a35089d0261f3d1572"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000b722fe4f"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000a415b2ba"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000d444d8a9"),
	math.MustParseBig256("0x0000000000000000000000000000000000000000000000000000000090958d4e"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000007a775c92"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000001fd2e756"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000000df8c0e5"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000374e9b15"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000b722fe4f"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000a415b2ba"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000d444d8a9"),
	math.MustParseBig256("0x0000000000000000000000000000000000000000000000000000000090958d4e"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000007a775c92"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000001fd2e756"),
	math.MustParseBig256("0x000000000000000000000000000000000000000000000000000000000df8c0e5"),
	math.MustParseBig256("0x00000000000000000000000000000000000000000000000000000000374e9b15"),
	math.MustParseBig256("0x0000000000000000000000000000000000000000000000000000000000000000"),
}
