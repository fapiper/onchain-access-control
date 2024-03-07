// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x0682e2dfdf3f135afa66c46c65e7a028995e450d3bc4869681ef00aac9823d4d), uint256(0x16517709562d6508c226ccc9cb6d67f52030391faaf5bb3ff52b8182dff1e514));
        vk.beta = Pairing.G2Point([uint256(0x0c401e1a4cc277f74e58cf0f854f8c37ffcd2efb5c87b1302ad229ab1e00f4f1), uint256(0x19d0ef40d53a2a05f34f55361a83a1ee02939ba1d41ef4309c314a9ff011ccb2)], [uint256(0x24fb7ded46f57570b945949361c71450f75118550c4b175af02988f3089c4ce0), uint256(0x2d576ec85223e4567eb5dca65d654b75b802e9955da6c09e398594f4b44d7062)]);
        vk.gamma = Pairing.G2Point([uint256(0x057a7b2962d2c0b7b6a6e3746f0c380e1c726b54ee53d22ed4f975c0b51d316f), uint256(0x0a475e63e05d6c27989e5ab75fc6ea9a91fb15480c8bb97acd3e3e70adcfad94)], [uint256(0x08da902e768d422c13ddeab51f55664aa7ead390f0d707679bb6728867c81f2f), uint256(0x1231627c860bf8addfc17144d371eeb61c95d3da40cd2842f48651a729f74861)]);
        vk.delta = Pairing.G2Point([uint256(0x13ed80a91c81fca7421aeea6adc66696b4236fc78831b1374d8b64a72aad0cbf), uint256(0x1d925b4619e76ea5a486acd5ede8157f0b737dad6556a5a9fd52be2f44dfe942)], [uint256(0x1b72670cbfcb868b5b96585ce32bf093707e51c7f2f38a0b94b48a10bcbf3a39), uint256(0x227a92728e3595e2471dfbc9ae771aefb7676f180e9b160b6a3d94ea6d61cc13)]);
        vk.gamma_abc = new Pairing.G1Point[](97);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x184991fc8d8baf6a8081e9f738fb98a783d14f790a69e90d18aa20129daef86b), uint256(0x0ef528b69fe4be6897c1774a499661c2c369c749f8e8689c5e652eefaeef837b));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x18e64878ec0ba0f2c234553a242c0031f2489f350bedf0267069b83774f4b636), uint256(0x2b92e037e0fbf434e1fd05c4eefdab185bed2db460105a4d42bfc62ec7d096b6));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x088331827d135cb081f879f492b31aa833dbf0d7e67c675d293d85656b88ecce), uint256(0x1d313e114dc2b497961c62b54d0318c685ca620961c3789ecd59b70bc0573790));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1e5058cdff06204fab6872b14c2d8fc0794fed5bbccad204b875f591269345db), uint256(0x27dac9eb1e4e01a0f48867771bc9a923288f39cb5780df24c0129e92040d23f8));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x13de04717b57c0f708881745376921eadc0c486ee467ae8a2a6880aac5ec9850), uint256(0x1f1d644eabc3c2e51299dbd024686c4b196457c92df9f28333b0eca893eda503));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x26d91760e064ed87e5288f837dea29d0c6cbf4ff6d086e2253fec4402f96678f), uint256(0x2509e6bd2ec81069638119828c191028837116288fcfeb8a239ca34ed084f4a7));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2384013950ed3a5af8f565686efa3cf2598c9aca395c7be6ab7e4aec1dc6a9e3), uint256(0x2e0e714354bb25d1a6edbf8cbc319bf7d21b0960308659bf28e3bf6816ec2c02));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x19ffef6fc6574750b7b75899b37f30c5355cb7ad6c2528ad7481cc462326cb91), uint256(0x0bb14c3261ff617acbe94626dfaf82e990212e75f78bf1b892b88cc3d2f3bf26));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2f97d572b023ec895c699ac764cc50cd07221fc2ecb158328c45842330954229), uint256(0x02f8dd72f0f98e8578b7501462ff20027fc8b3dc921f296bb0d6dbc17cbc4f5c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x19aba4413d2b457cfad5b27a3ad034517958f0a1432a4db4c599388df8955dfb), uint256(0x2060b19c6620a5fb41f711476bf1633ab6ea32937d7b48275a585be39b91098f));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x08a1653accaae7e2ce1fd187739bc7ca7d034ee6b0d3ef1d4b830e86a9ea6bb3), uint256(0x1a1554bb1564e0610be62a8898ed292660f7c6ed4b7056b43a9f6c190f91dabb));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2406903070c2fdcfdecc0064a7896497aeb25bfc07a7cbadd7fd85a000e7ad72), uint256(0x286a095b14745d7d61cd97cf4dcbb12cc0cd928bfe2e4114ea9d1d111402d6f5));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2c4257ce404e1ac0d23a8ae84d692ff04355e7b2f4514cb45fd20c356cd2f307), uint256(0x051d357e1ecc1de5fab5260f15fb67f50dc7c5417d0a35d3c55c0cf4dd492a00));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x20855efc429a171833d29085d6b0f85a6b16f002817b93f2d6b4704048431112), uint256(0x1ecaeb0ad8cb4c7f9043d8759b35eb90b0f6093b468633bb97fc58e481140678));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2e52f8826d0cb795fe9af6abbe81381a430b558b8a625411d18debc7084698f6), uint256(0x0ff632b6648ed0ffa9c8baff965f57d729c4fbea22aa2a20f3e0d012ea6c5542));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x03ed78dac625d2003df1e84b433bb7d2cdcd879c998f2eb5789ac562015d8b44), uint256(0x2aa075306e53c50da7e04ff0579ad3c4861615218c03362999f34ee42cc1ee76));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x00b985b7d8334d60f8e339f25332394672ab613e2dcafcb6ae174248f961c701), uint256(0x15712bed3862ed2adf9e1b6b4697cd09a0158118d4b563e56777b5fdda4ab29a));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x28fc294a48c44b2bf9a0f6681d575884b028687a99f7e62e83651a32a173ee2e), uint256(0x0bac4113cc3a22ad7d1b306f90c7ce457ec0fa970d0c80713e90f8987fccf0cd));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2c4eeadba0c5602f426358c8c3d9254bcad1bd242c8936e5ba5c3edd0a21dad4), uint256(0x23469f1d8cbb962714b5e9acabc2b18da96b54a14138667052fdb92f338d3c58));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x27f39730a6c1d6943ce9df0d7867261f6354acb1256fec7b7e456e99c2ae345e), uint256(0x215644798faddd2d95e348484a6a033ccbe3f16ee1df7b1bef56556a1d0c48dc));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1663dc847fce4b665220706b782eb25e9e904e1d00fae087c4022f1657bc30fa), uint256(0x04687bbffee95c80c2579e6340be0508b3a8b9fa2775bdcf2bb3882cf99be298));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x22f7d097768b11b5e338967ab89bb10e8a8cd5224f2ff89ba74a577b37ed3917), uint256(0x189a19134e1df0538e5ea45aeb100cfb75fd88b398a481e9429d404e9c00c1c2));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1bb8c055b1beee3f47a506bbaebf71992abf77ec86352f0e2228b68a6457852c), uint256(0x2930c791cfbeae9e5c8b0104397a1f8e93d7c847b990bfafe995cf86ddc5c5e3));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x19d4af1c44677b1640670bb310b8555249546babcb46ac85f6e184a78fbe5fcb), uint256(0x12fcc3c5df80bcc4d0e73f5a69855f1a603fe67b441bcc57227158e0dd220399));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0547ace85867e1d52b0112406d843c5427dc7a36860b85e8d8b00660eda4ac6f), uint256(0x0de7bc0348f9aa456661659d7402fdeea6fcf2f3b2442016c8c92e6f42e76350));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2a3e09f30504034ca3000d4ab16417cee6bcdd77aedec6fbbb5c22f76edefcd8), uint256(0x004c78caaf05607cde3aa4b05789856863e05abb0955b27acf4d3afe1444f045));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x034b2e5f136b9871d2c10769a2389c3aa67b2ed474a75ef23eed32144251343c), uint256(0x0857a6986c089e7416c2fecdb69a76db134e485d4b3e67045341e505759dd471));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1919c42d5bfc49a88be3a4cc8182507c75be2050e102b9e9c28e0e4c78e7c649), uint256(0x1427548af5b02c760f53e3626dd0ea783d64877f5cfd0e94b68e930e165a5fcc));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x27f29a9c7607e77b78a77ffa126c405bc3750b3c16247c2ea264754df950aae6), uint256(0x08f676f0bf0d848ce5117b897d397b58cc28dd9576638ef3770574bb89bfb0ec));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1afe9806706b2ab755685d8ead99a910c61119bfa261f61e38fcaca943d15a86), uint256(0x2a7d3c160279d0805c40333e212e62cf5a01f0ed298555dbfa2da32819e4baf0));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0f39b9c98d3ff0d463c69e059e240aa7837111abaa50a7a57c80f372450409bb), uint256(0x07aec56f826d36e26c2ac764fd948fce3834ac133f8476ea772d16a6c78b2015));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0518b5ca34fa8f197787f7c40f4b8a5f016c5186145f4d9fca0b644e18b41953), uint256(0x1672afb4647e8c494ef8f2e1bdab84f9dba1e9ae074a1180f6759a003a2b2522));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1c077736f0990397989507ac81ac82770d9247fb4dfa7fba5004e35179fa024f), uint256(0x28abd18343c8ea9d06369b35960d078682e86ea57ba206970f73e3ce04cc92b4));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x17ee3ec7a0a76d92e9260090812d16db462e71836e03ffc2ecdcbe3ccc09b73e), uint256(0x094805ed7fc21dbfb971cb4bbb3d7a3866786caf9375d944d6d24e7f129bf924));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x1ecd8ed617aa7f017c356937d775ba5ef8c5f4dda4a518143ae1f139f34630ad), uint256(0x0a359ccb58ce084dc137088dad8fcce74918b1c429e72c012d9077bc04bd5fdc));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x2f55e8e21fbc140491529856e585131d173b7660003bc9eb133abf99542644d8), uint256(0x1d268a471fa0d7103f5eac0c48e5180d715dcbe5c937a19289bf459e0313c438));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x2a9e8561aa85a438475b669e8b3e4c53c62afd5ad7e6382be814195f69ee2fa1), uint256(0x2675597c4e57fa46dab1ef8aa82467cd779cffcaaa6ff7e5d9eb211b7daf1ec3));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x14c4337cf68fe2301401b4c40fd659fa9da7f24fab12ddd3b98f6b1feba7705a), uint256(0x00ad15fd23405bd81457147bd13dfb4499c8212684a4ab81ab80aa2c34b40292));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x2deda686209a14e9b41325b732b74054681e817d9ddc268f7cb04e9712328f1d), uint256(0x0c2fd620b25a1ff1a04edd58f87f22e04786968a2fc66b8bb467ba37971fb9b0));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x08ce8cca84dff692f0cc21576ab8d7f14489a82d3cf3cd54cc5ffb074b8b19a7), uint256(0x24f29916eb9ba0f7a38427dab0ed0cfc330c14baa226244d7b757751fb7da644));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x0105f68612d001b37afe64ae9c43aeee80c507f2b2f06b42ea2849d1f6c7d793), uint256(0x0b3b0048feebaad304d922059594e9836b8527c84ba0267c577c4d0631b36b1d));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x286f3d5158c03a31999760a106256dc08bf0c3294532c553302fbc11bbfc9bdb), uint256(0x2a0d76a438db1df03d29d3976bcbdfb8e6b47b67ec3c307a411229d7e3b890e5));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x20a2b8fbfe932bed94561b1005fa42c057e9fd0791a965fb44ad24cc49af1370), uint256(0x033cc3f0bb8873087904e4c63f3bd38d1561867cf21af23ea64a9dd55f010903));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x2c7bc65e2e0e05e5cec262e7151e3fa56c9e5eff91de2c904f986349eb38dbca), uint256(0x1753d06a250bb5aa9c8cfac7d7eeac7ae278b2de5521e64d0e5934f5b6a65e8c));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x169c97619b274f17f13936134eb69699e19ee66c275959733526e750c0a06342), uint256(0x234233f7545029b6e202e2eb61b419e6d24f4df005420de672f2e0aaa1c8659f));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2c76d0f1ecba4e62e00744c2197a8ecc7b6594a42139de1b09c3e9043af6b4bd), uint256(0x0bbe7e45a79a14dbee8d7d4ece26dd2bd40e89e2c68d9b96e9565b5ce5aa834d));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0243adc6c630b4336629d75e6c3f7c633953631652d6c7f58be565f5002deaa2), uint256(0x160f8e2416b019fbfe749443f2c841932ca8ef0a9c6f7b6a2f57e52e40dead16));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x20892eccda4b346c38602a4fe5cc0014ed34b89cfa2eb7e0556f6edd4f5fb6c9), uint256(0x2cc008469704f31ff2704c5d55427da48bdad72ebb28883598c6c510d8b7a09a));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x155c3afe1c67b85a2713e784e67df42756e5b01e4ddcf3a24df9caa1e324da5a), uint256(0x10ffbb0bbcf93a5586eac2cbabf1da5ae6d2a76c0b53284c9fe0db46a97dc3ab));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x2c5c2b7ccb4fce381593f9ce8b07c1a82860ed38a4b9fb6964c32d77d638f3fa), uint256(0x1ddcf9d98d1480aaa322eac97ee1db6afb67dd425f278d6045532d4c5a89768a));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x10138ee120fd1113508fe22ef032d08692237c13abbdbf4a64657ce28b164a66), uint256(0x12d44702f16f944418fd6915b35410fddc7728f594eacd8db4a5ff4cdf4c789f));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x08a8effb96265ca7ab758386aff9d34263d0c6b1977d4151773bfc73495e1e11), uint256(0x2ac0f8a6b2a738432331d2c99f0e76900559f1f9143bcc5cfb5608ddca5aee32));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x00686f7997fd43deb8e60504729c2182d21d68c328a044579b25ba5f3158e384), uint256(0x0a25999785bda05628a00d88178808873e8d7a185dbabc6b35aa879733c2acba));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x11261fa0f3bf28cdc88b980077641e42fabc11de7789e7e2a7ce7b78881ac3c1), uint256(0x0afef83025309b0593f47ab0275d9bfc43e824f8e2cce520d7823b52c13ce518));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x256a578ac0cde0814f9d41ec060dc05f3510030530d6020c2ab16e0763594284), uint256(0x0758a00e486ba20fddba0d7a2e855671017d5d5698a48051b649ad966d73a59c));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x250ffe966985bf3265c7c85cc23de69a140b060784f52565cdfc90270dd50daf), uint256(0x0eeb41745d217da27960c02b59a84f1b8715ff9313464cae3f87569b3b52a66e));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x215f123cb0808d05e5e534209a40f367d972e2613e3f349e57ffc36b0cd5702c), uint256(0x0a9024f661c630e3c760802257cedc1d47bed19508b70ca0d3f7437a273ed957));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x12e4853770adaf3966e2aa6b6e9e7ecaa23d8746ad635a098ea36e61f1954f46), uint256(0x190a693fdc72df5511383434ef1be6a6278216e7c53af8574ff7eb405ebc5766));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x2a06b720259be4bc0f7475210b7153112d792ae08169cea51f1feaa977610c7e), uint256(0x021e9f5c4c514bfd2210f523a1726ab43cec81452ac2a85e45faf6c43bc4826a));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x0ea818d5176d63c2dfc2deb08eb6d7c2038b2b5895ff64c2d357fbd017453724), uint256(0x290ea4f248cb3fed769761234a8a579efcbb85391eb5f3c7e8cea826d5b988fe));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x057fa3710dec1bd5011071b0b9dfc79c8ef8828b0bd51df104498176b071a681), uint256(0x1397a15fe8fdee658c31e07d9f8bfd7c1bd7245fa7be8823c54f1cc2dfe784b0));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x1badf6ae0c3a4e66388bc6cd099e3b934a9213c935ebee31b9a4317c0e72e9df), uint256(0x1f9cfb22ceda21408e53cc9c1ac98911e3ab834b093c35dd84ddb8cf27ab5fdf));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x1243e2891e08bcf8fe0e130e42f0fa729976ac4e8052bfb0d0b99a212e38144f), uint256(0x1cc250eeeaf8372ae80238404d76eb3342c22ccf8ba28c17e8ca7254103b6a3a));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x145fc984e1b896115207e37f8978f1df21e9a66a939b74ab259ce531735590cb), uint256(0x116233248a5cc641e6cf4457ca8d2459a2cea8fed65d39e58a496fbfe6664ee3));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x15a299873079271cbe807710d8a063e143048ffc0ebcfd9f4aeb59b822f5e824), uint256(0x20ceecbe400c15d926f8e7d2cf6e6bea6869b14561acb5d8a14d3fc207740621));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x18e0474925174763efc6b5d0b0e496dcd213b2da92e9ac9519cb71588b45a058), uint256(0x150202e1133056c4684da502946d45196fe823e9fea2da1ee9d491693556aaed));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x18f6e0536c583e2bda711c58f9a7438f6e177d9a0a4e61ec02ad22992b4e4b6c), uint256(0x12216d8df2c2b9a772ce5881641c0ce96f5efb1abca40a9284697106c0ae6b97));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x27ade1e33b2696a15145a4882eced0236748812f4d6d831b02bbb81ad251d187), uint256(0x2bad91784872119276284699cb3ed50aab2bff29633e3b11a590c25bb4700a83));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x1cc8b68f90839180f8eaf2458344dd5eb6b396efcccdd9aa7c3e23b80ce533da), uint256(0x1c91387c72ff7f7cbcbf221be79fafa75933b98e4a93b4dc13d2a439bc635cad));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x11558843ef9b78679a758acff166dc0490696c813842f6c5a2c884ad5f90eb1a), uint256(0x1dc40b68915322a029641f743146d30a931dc2301af51c819bfa7047450938be));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x1708835ace4dd742a1e1abb931a11a92c9fc6d979bf5f801cb272c4d8b6dcb05), uint256(0x1910a03643c9912f953a5d01e24b5c0c0ab3234626ffd7a0f099decdb1801df4));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x2e2f5aed81252918789bc84af4ace022f46b70d5164ba7759b5f73222136afa0), uint256(0x12e47f8e78c3548f9e5f7f3eb3708f3eeadde66df22cedb1ed7a22134fa5c2b4));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x11b3110d007887bd889163d1eaaeca80d361b37317f18700a1b18b399cd9dd87), uint256(0x0f3cd84a9ee6e44e5f9605b0d440c88a963d60c3db0444d7558c1e2fad79874c));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x27187c53d500ba27acb3a61dc9bc3c94324e61658eecaefc73b0f7f18333cdf5), uint256(0x0d4e0eefb7ac56a021ae910713346b5ac96978e30319b54c4bcd31a7e4641e50));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x0ae6ee89aa5e45f581f4106b64f50c518b3c929ca65dd3d0d19fc28d5c31ad28), uint256(0x0722072107a4b46427fd004fd8a2955bed385ad38f8913f407e4c2731849ea57));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x1f262fcfcef7ff1b4959a03ac6a82a9ba91cdfb0090f6a7cc543dc2b9afadec9), uint256(0x2169de8cd64880ab9f6fd2bda7ddc2cd0cc6a93976d31ea2ab71064ab13c8178));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x18a332495e3e635ab82658bf7e77aeaf37bca951bc3fa176486d3053f48cb0c8), uint256(0x2358f13b8c69d80da2a9be1698d5c40a9e4eeee1bdd05bcb4d9fa15d3002c18e));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x09b6d9f10b515af28ff25be46d5a24599e6f51f698acc393582ec8996acabbfa), uint256(0x0d6a30df9a549043999e5d3353bdd2d1122c596e4179af4473666ee002a0e05b));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x1a0e0d541e01f19b1842fc5275a60befa007997602f281e9739563ad6761e643), uint256(0x2165ff7f9f3bb153587909cc754c88df8adebff51a4dad8d0bd94d32a5a54f16));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x1b0dc41b1a41b697ddf2ee2ef1a76a38a2c5ff89531eaa46f0fe44f57fc0eb41), uint256(0x239e9c0d4d3574e83d7faa22c1f98e12b259077b0a5b53dafbdf95bf52a3722d));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x0453e310bd21b9b4c18f3ec6f44be37546f1e33cb79e92179516074958239a88), uint256(0x1faebe4cfa8b8929f2ad3c0044cb4949e69f77c6657557ecea96e1a190d89314));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x17403224718d1b3beaa8d5a12c1a3477e2284dbbfe713e8afc9c71bfcb8a209c), uint256(0x268e41902e063096fa52a73af1f3e98cdf93a77d889d7cd8cbbd61b10086d203));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x0fa2eac4ae02117ce4e4bc9e950899218fda9220724b3064296ead5c6b6e29a7), uint256(0x0591deec35f7c9cd94dcc20507c3e841e34ee54d145a56134ce096151ac45f03));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x0fda11fb5ec9957be807be7a615fcf442b58df2645b5ac1283f12508e9924020), uint256(0x1e0f1d6bd10d82a74e8fb893ada7a895217b9bb4eb67b75fcfdf5a98edc9c1a1));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x0e10163d8ca6d4d9f58cc671e5375dabf24a2b9567eaf5bff7b0a92da28a7c8b), uint256(0x1f5ce128bbce2ef57876307d0a69ff163a0be3eef343889dabc25dc38ae222ff));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x25e2f7429f685fb7e51fcda974961971ae46a47cddbd67febc050bb0c6ca71b8), uint256(0x1582396a0ea374c90994d0f9db42f39ae85dfad2f0c7f14a85995207351a5d82));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x2eb17767e7bd91367c601545ffd3d1658a5a0c850b7bdd0539e529a91536554b), uint256(0x15036bc996db94547989167c806f40737b205ffc435a65e6287e93816b450d31));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x1da95724ea3e4841a4d9359211b1a5a2e17d22285b7e5a233b614acc48da6fe3), uint256(0x09c1cbb03c6aed7b9ace74d142131c935f93505fca46d329819e9722b46e7879));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x234a35af2543296f856aebb03681c15b0799e28d807165b7bec207bd743b2420), uint256(0x2d7992eb9b7172d0fae3a0f2fbafaaf523543d666741ecb2ed2bc9cb7e03f6e0));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x2b54ea083e9407b6539fdc8dc7d4cf784c42f734a496bd332d650eccc328d9a9), uint256(0x2f5f3f6fb11b0bc56c4dcb44ff82becea51eac7ad541454920d16e61ac8232ea));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x27ed825948448a391628834fa26751a82a59e960cdc413278ffd19fec099542b), uint256(0x1d84ec138e3546f8573cb5654b30f41b9d9c71aadf3a7580a53c15ba8da25f95));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x22f8e56997beaddc6e1d19e8870cc5f773fbdb9a3c9d38bc26eda386e8d7c4a1), uint256(0x01e5e9333a3096f234e594fadad62b59faa3842c938b9be518af8efa602ce5dd));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x2f2093c4a2eed91da9928073c45e75d873c918be88ac82bf5c3f53031abbee96), uint256(0x2deb9d36818bb8c866fe0e7eddde3ea3b8b0f72498ad41731dbd3653f2fa1aaf));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x21152ea2c6627ca616e5fd0a5b614db8f2c31bce692525a3ee36c0c13e3b5309), uint256(0x1fea3fa8b65f8903aee4b45dd3e9f3d2cacff07a6350670534c4c5cfffe97ffa));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x0bd2a178d9c3bf9cb113a188f9241be17cd3b5fd32e4429ea993d2af9b739d73), uint256(0x16ab9d2ad726f812f0272ece916bbaf74795c99db4a206e1080559cb634eaf47));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x0514a4c3692051edbe0811e80f4526a5aafa7168b4efcaaeb24169c07d621080), uint256(0x21c07d607ab7647bab0c5c86c6e93c61c19cc13838af24bc91c6cf436426a582));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x00937f95af489d29647d259bea95abe622b911fa4a97f537d774767fa64bc133), uint256(0x2c407b7345b42ee690dc7c01c7de2345bcd95535d69659e6f056486fd109d5f5));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[96] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](96);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
