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
        vk.alpha = Pairing.G1Point(uint256(0x0b8d5edbf49464909455606368199c69921cd303032c2f46cfdf79b585973ed6), uint256(0x12f54e7d0f6457f7efedd8636639c367deae04548a28e218249417078af367e8));
        vk.beta = Pairing.G2Point([uint256(0x1eea683020fe2b7ea614e61c48cb9822333a17e323562d56cdebe1cca1e017da), uint256(0x0a96c01adddbb81a96947568280ed2fc3d4545bc21fb0f713b64380973671a71)], [uint256(0x2a75006883feca5d097ced7a21726375edf0ebbc081d2d30347bb75b8e47d44d), uint256(0x0c74b11fc2d11628ad51668375d823e5a75ac005aa741395fd0351c267b14681)]);
        vk.gamma = Pairing.G2Point([uint256(0x07306db910029c28c590d04d7e6c5961869e1b28e19fc51b5d1158c270b0a2ea), uint256(0x0486acec65d37190887cf7151ce87153b5935f0955acefa5abffc8b943f4e354)], [uint256(0x3059a7c6ba542255a4856208e2820c3b6b2f3954e91b845977fe5c213a96500d), uint256(0x14f76524d567b8915a5ee509feff89ccfe3c85147d735fd699da9ece6d686eab)]);
        vk.delta = Pairing.G2Point([uint256(0x2cc6a5c6ec64438d3c09d0b1ec0783b003e416a988d62f6f1687388175b4d124), uint256(0x08226c479e597a65bb6a72b0ecdf3b3c128e1e95b2aad644f749b5f84869325a)], [uint256(0x16ebcd434ec2a59b0f63b144d58bc12ee3608914efdadd355338787cf6b7a0c3), uint256(0x298bc19e4ca3b0344af6a4790307768aef7c6f9f9eb9d02b44044d6404e6a8c5)]);
        vk.gamma_abc = new Pairing.G1Point[](59);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x27e5ec7d4cc53f2f5ccba08453f33825c258d40837231f8340d5f9e682d4ce7a), uint256(0x04da76cfc46418468e03157ba442b56677e62bd60d7b724a605f2a85a35fb7c8));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1622b85669fe5005deec2ebb5160f06dfd81fe31bc571d82b62a50e0e4e8df66), uint256(0x1839bbe9ba743d793a1b71869d753dadf565cd735db2c0b68caebdb4a1488959));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x21d116b7d0e4d2fc8f228e41d387ae017f56aafcae979d1e622be2cc6030bf19), uint256(0x20549ae9a7c5de1c752cfd504e24510db88e53f1952eafd80132a38ea132db88));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x21d4f078482bba772fa89707ef77879ace92bb3795134518eb3c885305f5eb4f), uint256(0x0ee4c351a978206b69d3e68bd5ccfe4ec65179d2f263a088a082d57fe71b2b50));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0036024ea51c1ff2a96ebc4de5d36bcf1b015c147f6e5baea6dd0eef6d664186), uint256(0x248b942072049cae3f19c4fd941d223490e70cb9615a5891743455a84de476b8));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x07e5f84e681157223dafa12113ea4e050589a71890a812f2d6d6c7bbfe000487), uint256(0x17fc2e8e04530463f47408186c2437b51f505a7f434a48a76055c140e8852cee));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x19d8f6dfdcb4868a78d163b3a5e3fed87dd6dbd4b9b1217014c77a14bb732277), uint256(0x1331f4ab7b824d37d58fa308f79face871440220c78373a0578ecd6d1e63d7b5));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0d714b94e1853baa39e653dc8c4d144dca60c820d9c81b789b56b475c61e55fe), uint256(0x166291b198c72fe4be790698701ad7e58fcd766e6dbbee78bf37386b6e7e01e7));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0279eaca2abac91446cf25358cad94ba6e6e0d62d399e02ae120fc515c4d3b28), uint256(0x1e354a1c50ad345d38abe0094d0bf76fbc23db2c7dc6ab2e168186a796cd9bc8));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x26f08e37a7f597956989f8d784ab95d939fb4adafa3a4d4400c09f3480e3c552), uint256(0x0252c5fb73ff8dc7ed62f6b2e13544e53f9719f9b7ea732ef849b5d56804d85c));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2e7d799a8348effaf222e1b363550ff9803c759e24d98c7c7e837ee85f9e8507), uint256(0x0bee9abeeee92a533766c78de155402c998248ff4aaa66b234abeb32c46ec343));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x11c0063846190ef77f8cd826666d20a33c2211934723bda7e5109dbd20851074), uint256(0x1206517b321a7711e76332df1ea8455cd59f4f6b2017188dba48c20709dc8691));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0a2510651da34a41d5fa98b0fad52437f77329cc813c725b9e0f163706294242), uint256(0x28c7d9b5c51ac609544c3216a77ce2cc9c269e8b22ad3575ab31dac070b0f7bf));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x22bfd089e2b74afd416ba84c75622fb1d53f8abd5909f89b6db67c0aea4f540a), uint256(0x25e3580cb62202b6de2b3e306bbeb017538ee1de35e5266136fa0d89b02e975e));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x22213c2f4a4aae87763ead278a01c3ed845869c0d7063b7613d6829ec8e032f2), uint256(0x1faea076d9ce82a09536124b11db0aa09418972ec31d74f6bf53dc1dad4e4bbc));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x27e815da1d9f7a2f251b32627a7550216b65f85459bbe683c110202394321537), uint256(0x17dc6c90d0695366fc894c3d24c5c9ac469810bade5293ad8061d08bf5a2ec61));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x153c56e6a7a67659bbe1e05799879471aa3ea664ce351b7b60ef107032ee7f90), uint256(0x290f5f65e571125e3831f3c7074ae5d64585b23c9b4d055449be98b8101c57f3));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x24f3a1f56b4c1a6816bd15c7b1e8a86ef2107c59a8d2166bc51e24cbbb1c813e), uint256(0x1ee051579c5a5b9081f782705e0ff726ca8ccb77bff9563088697c070b57e0b0));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2006e82c14c7de4c46c4fc71865a4cb80a678a9d9b37659abffda935b25e6c8c), uint256(0x2cd4a35ad9de4158e0f960ba14cd49bf64f18a66b12af691aceee8d3e1c92123));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x095658f8a423a1850b08ad08a964871f36939466de828734f9f967e8e6107fd4), uint256(0x1d1dca8b8d118a959f6d745bd3b91f1d296e74b3b04728defa7012aede0ba051));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x26448de3c7516b9b9560f9cb75432eeaba20fb2dbfdd2561a452adebc67a4405), uint256(0x230598a224f3c59cc493344c0f7d6a2fa0e22de94e8deb381dc6c484d1e79b9a));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0e96b7a1a3a99b2b2bf0654e9ad156ab3ed037f97f85889fc5807af4d77fa4ac), uint256(0x2457844ac1f031f31af12fdb3772cf3e8266114af233bf725877f4c7b143689a));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x05e6110adf405e8e64c83bc783b1903376f99cf4d5ac810e1781ade072bded90), uint256(0x0a83287b5c6302923d3ae9e3c530533565f6d15330a81d157e6688f03b8f23ac));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x06c77847ec663f31e4337eaa017ba095ed1ed04aaec037e9e9937f1d99036f06), uint256(0x2d7f3d2b3f8bcc71e97aef40ac28a3aedc92ada03a668fa021de85688fc05bfb));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x3045cffeafbab764f7e307e14a1d506daba4ff9de4418e7cbeabe47810e44a74), uint256(0x1bfa3c64fb99993479af00c1474ceb93f69265e18c8fbd8154e6d4134a2ae9f1));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2b1e3028a992f8aab500158920c894100bcc574b6d5f6c46ed51e2e9d64bc5bf), uint256(0x094be6037e1dbe54d48c3889f499cffa7ae69adfb77a0e7076f35b3c4452b420));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x09d17752d63a4be90c0dcd9d8674bbb04c11500ba4f161263467308322b64404), uint256(0x0be9a7b19d58e85220f0b162883044b3fa6fabb56a815b2d3fd72444338d3a2a));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x12503047da49ca7ecee3082f086661810efbf1c3cb2595f8de8a1f6e032bb6b8), uint256(0x1cf87391384d8c4a070078cd1d56f908118d88fafddec7d809f25bf6afbc99c7));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x18b7ec8af6dab47201200564280a65a7064fc341c56feb2590ad01a4760b8aae), uint256(0x2a04e55f6f1e5f2a4eaf7c61d9545d8fa8b77be6fad93a357622b0e2a697789a));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x07b2f171bdd1e18ebdd27a767139539620a4736adaed3baf198d3bfe827c6ec9), uint256(0x24cffe9fe461d9da96292e0503aff57e019f1654f9fcfcff57d3242edf3ad322));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x297732ac9c9cdb0000c31fa8d0b60276fba5ac618af36a901d91f872bd56da64), uint256(0x04b251fecd92e098eeee383963f053ea530096488f1a7e4da3c5661618313f65));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0ec3413653e8167fe1f1eb3de768a74da67e7d6b4080c1d8c67634538158b712), uint256(0x0c0ffb592d52f06ee42bce0769871b6cf0fdf73cd05df15ed0fdd7d74eba3734));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0efe5963563f1e242a07bd736435c9e83e461fa00165661c76f47639a67b9726), uint256(0x3010b9ee96307ba2d91e5166aa9588468aebbf262f2687943b9d6603d1d6f683));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x229dfbe2ec4583b7a391fa09b79aac3c9a42ec5670946a65cc367be501f8fae7), uint256(0x2e416c9900ca95d6cc1fce149a2f0fb987dc5da591f4ff1950021daff2a8e7f3));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0e474563ab77d4b6fccfdb46b2680dae16bd31934e01b7740d6e1b5ae604cca0), uint256(0x2c17e23ac8399c7e27f93564509d0d6f05dc134e4e1e5792b46ccfe1192667e6));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x1719befcb510a9f2ed733d2f6a49195f876f31e02b9d44853e76539c780dc37a), uint256(0x0ae8e01e29255a1963c7ee8cceea22e0ab5f22116d98a6c87f9301f4307b4e37));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x0ee0529795530de5d86525df021d696b529e79db561b467fadbfd856600c8866), uint256(0x2716fed9245dae9002c7c58dac2688affdd654ae393891cf8decad3406e5dcc2));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x2ef2758da8cc144433ef2d1bfd3288ec8a4bd81e8680fe029e4d4a5e2ea41fa4), uint256(0x0ecb2cc4f9cec2eeb9f8aaf1a2b24485773790576f9586d096b8c4427c261d95));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x11b2945527df64fcddc8d2cb3d6a243ad717e788f6e4cad558bc2a7b2bd607db), uint256(0x1afa1e3c6b4e903839d76e3a1343625e270cc3049d88010c62d742472ece72c7));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x07e04b2e9f7889496cc2aa96d615e98d63ad14ac5d25c97b9e1e2010e4d09df9), uint256(0x07b90a16198c0eccbde5a141b52d1c46ed6037f28982c92ded10ab4d0e3c730c));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x15137480dcddf10d96497de77ed7e72e60841e52663d6b7e6cf93a49348ac593), uint256(0x1c49d74e48353d36e1527fd9811f74ad2497ed21c9fd726c92e433252d0f581f));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x2597158c785a051a4e20954316fd7d6f0205f3c6c6867cd9510e6ce8ab49feef), uint256(0x02eb3fb4385602409fac8241e3e1a7342b089ada0be77b083c407146934f4ba1));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x16668a6881caa73b5b8b910e7dd88dd557f962960a5311d1d07288f3451db4a6), uint256(0x053e2750023dfb10ac2e0bc5e1766c9996f7e9fef8a3278423966bea298d0bd0));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x2966615d94176a54f45068e2c2b17c492e5e8963651c698104c2ea2edfd41061), uint256(0x1dcb4860762c32ab9da6aa236a1d58689972996c33c8cc29312009bd247c5d89));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0552bc1c46eb9ed6ee1cc5021e4169926c2b608b388d5598d26ae3cf604087e1), uint256(0x27dda347dfc639f228f88742cb2fcc2c573c08d17fd184853b127f918aed2e63));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x28a4937edbefc7552a6f7bf82aed3d488201fb0a48319a3f419a520aaacd97ef), uint256(0x11eba15e1d383c21e145106154cd7317ce2f7b455d94bbfb8b595956623c781b));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x021424c4ef6b362bb73f33ccc0f62835f20a96601de19b9ea21a8448d535481f), uint256(0x2d7bbdd1f00126319edb707fc79cc5ebe3c65af15cf6236f2ce5db6289ffd818));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2723f4b2d3bec008a818c81a82626a7f66dc2100f54f7bd8a2e0bb5a79041835), uint256(0x104feb27261fb03bbd361a687b437e04475d0e343f637a640788dfc627fc4805));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0bfd3b89897c989710e4393a1794a893c50238f971ac1c886c35ede3293cb4ca), uint256(0x0b42b34e759f0c8147342c4e99bf0cf7e84b814abff1b5dcdb2d395ba1adb5f8));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x043d4bff9b7fb29f226645732dc649ba1bea8df5801c881ebe148064eec0d968), uint256(0x16d197f69a5fe5affd2a2f4ab664d58a372e89edbb29a4ef60a29fb78d412452));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x1075274e96a3c4c20fa4ef823ea8cc3b1bde9ee63ab927fe01a2c4703e38b7f4), uint256(0x0c15d06bac5c35f65a9afa56eff47d963633d773115035307c8e852d61ffb869));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2f82f8d4db9dc49251500e978f10a5a2ef3a677d3054c3649c2e1145270c4661), uint256(0x281ad012f0cc0c59fceadf411b0e95356c6623140cdea9a57195557fbab7b842));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x25bd19710f3cf696b9514a8488c58a933ba96453fe907d85e0d2eac634df79aa), uint256(0x025172b5829d3b70d6424edb6f68ccb14529b0529505451e7d237050e963a448));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x22412f5269f327aac92dabe7d36db57e33661df9ae77e6e453898e93c4e90e2a), uint256(0x171bc82e920d9679241d971c726676dc9b67271617be2fe78ee083c353a3ae11));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x260bd63b4890bd066926539f96d347df1997af6edcc0e8132520286899e9f73d), uint256(0x2c13160fa9d1204f735c5e756113c6eec4451e45c426f99c93d564d57fcbdbb8));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x20b7c47cb9540f5f91f1cda97f837934d08f4cf29de36313e72555632b7c9fcf), uint256(0x27e9ff8c3eaac4dfd146d448c390c4a929d785f12bcc41cbb1f50dd7490728d3));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x133a4274b27d2bcf84b46798e91f08604d19dc6f1042c6cc4f695c479234276d), uint256(0x02ae870d16a6424c2751e1fb5bb87b4eb7e900739039d0b5b799c0b3ed1ec50e));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x0d74374e70522350c38f0bfa23a4e535bb1473367eac3a7544f0ae31b173e395), uint256(0x0e034f58eba611d69abf0f6a4ddcfde0a97b54561685d4ceef7f20d347377c88));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x202374010b88fb6e36e49bffbf06b5d29335efc22ff08d145b34d74276bbb888), uint256(0x0e4fe449fe581de7a7a6fcc46e6161d8abea62d78e5c01111872f8e9a96f487f));
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
            Proof memory proof, uint[58] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](58);
        
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
