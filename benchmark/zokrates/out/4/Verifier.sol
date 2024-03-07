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
        vk.alpha = Pairing.G1Point(uint256(0x1fc7a2ad28632c0799230bf62b9bfce33a2bca8226bbdc6841fbeeb5f56a299a), uint256(0x1c18645c2c935a436c1eace5ae681198838eabd7bb9b3a336d497c1a32501180));
        vk.beta = Pairing.G2Point([uint256(0x1ecc3d48b66d9dca0b5e3d4a1dc2fb1e6fd9bb7f3912487b75b0c307a6f641b1), uint256(0x0200e592e8563f15c0a4f12727acf7d8a5653e679b4e86e1e457456e67c5ac2b)], [uint256(0x0be6ab20432abdb7e8cf4bf4565db199c3cca5eddb138fa50f7becbac518a6bf), uint256(0x0c5d4a069566d728fc2e8a151d1b9f52b17cc1020b48a524067985ce01559391)]);
        vk.gamma = Pairing.G2Point([uint256(0x155ea4c5e05c3c765e99efb78ae2f33089d529ac6aadde57eedec37bcf7d2e16), uint256(0x00b50359b915d8f01176ceb93d03b1db33dae610f1283ea8cad9bc67dd66b14a)], [uint256(0x2ea9c1af39e0b86414bad73796458ebda96e981ec58973e18ff9c178c80359a6), uint256(0x270c80a3ec2189255fb1e13ad7ee4f92efeb710fc9c7cd038d248b6a79937cd0)]);
        vk.delta = Pairing.G2Point([uint256(0x29593897d69be9bdeb00930c096c73c7737df1d4f52a14fd59d8e05abd594335), uint256(0x022f22e3e83630000319a433981bdcc959e9703d59659df140a7f7615c628fb8)], [uint256(0x225f9d994e00e4f789530446ad69a4ac809e3947e51fdd3e1398a83679db471c), uint256(0x02a92c64f13cf20dd69cd2dffb5c4bc61d84ec2a22ead4c076730f38b0f1bff9)]);
        vk.gamma_abc = new Pairing.G1Point[](78);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0db408e9263f28310d3ec688657cb4eda18acb7c4f21cfa67653b5b45c730fb1), uint256(0x1aaa9843c93e72e59518bb3fbfc76852771bfb890516115934c856db1dbfdab8));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x289e8804091cc5779b211b2ea5a9f3ac23ea29ce8ab52982be460ec060eabf1f), uint256(0x19f6c876f0037616c49dbbb4bf1284965965b69b57ba770b3b713a8dd1bfe13b));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2fb6f0c824283bf70b8fd195a34e100b1de804b6f98c3c376a2b6366177e8356), uint256(0x16c14b2ad71d604ea0d81f74e2f9c4c21dcb6c0d98496e452e14450bc06b3b01));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x27f00f3adefc4e04369a999eda9fc2c3e4d5738d181baefa9c4422d77111be70), uint256(0x1020b8e1fe2fc7267b42c44ea8debb565dc270da34a4209d01d8d84aed411969));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0626471250cb1c0e57c6e0f65cb6615308cd34666c7d7b5db0eb1346a71a706d), uint256(0x106668ccdcf2cdd1456152207561d78a13c69a7b131361eb9254edce3e2ae6f9));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0b3d33be5d9c19cb76e373923c3720e6d9a24e573f05db4360c53fc9c2977742), uint256(0x30455099a6366959f3134cf81e3a84322f9005a36bbc2fdb63a3e8448c6dc28c));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2e8c2e2979bc0843340fd3ad19ddf7e824604cc2033332bfc03354fbbf4bd5bc), uint256(0x0d18e38111fc608a1ec19a42476c951e05f3917e82efb08fef3ac222fb8abc60));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x014f2e0f60367685843b0c824aca344e1b3561e1d491cf3e9529f1597c7af898), uint256(0x05327470e0a3eee46e4359096a60a12cafbb9c63b7213e05a377644d4782c04f));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2f34dae15c6f91308187f096a2ad81f54706a64205454405310850db2eb74a6b), uint256(0x1b27411471f9dcbce2c4877088f83649d355b6d2df56fe465c7cbd647b340036));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2bcc59bfa275261a586e096a1f0aeb16c5e0841264f388ed2e738be9b50b63e0), uint256(0x0cd161bc01975371b30416bc32103d66f0935e72f366b7566bf6697d2ba73fe0));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x060a6889a0aeb9ec1a43da216e3b7af7e72769d9c9289cf551d9d71852187aa7), uint256(0x1446d9c8c9bd7f3ff92493b2cbc7993b32bb6aa641902249728f542f4d4a28b9));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x009c97963d14ca646a3609453637f9084ce23f8ac9241a4906f1682adfda0d37), uint256(0x1665a6b99859f29b7ba056d4d408476aa102e528fab05b2aea711a5260581f74));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x16bd33a4ba97280d3d68462f68bb20f29d301acc81870d4101c8a0f5e4acbd8c), uint256(0x14983711e01dd9083e4d0ff327b21182d776de97eb0d3f5e48b78d8d63c273b9));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x02e29950dc7586285a2a28fe81ac6da294f1a2b5211cdeaa0b4ce2ecd521d0a5), uint256(0x1b38ebcef7da776fe73cab1d600256ee89fac4272480c5656e30fe4033dc4bc0));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0af8eb86354a6bc3d0f48fa09fad04005e2337bfbfc0f66b179278ce31b211ad), uint256(0x2066faf3d1ebd55234f38e80657250f26710590651b98b2ab8453c3981a438ef));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x00187f2aa5bbe95aca26c3bfd2907ba4c8626edcf30d4a71aef4c642120ac86c), uint256(0x1225026c8003ab9e1c871e4b86a187cdee396075a8edbffd3187b8bb432b1111));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x02871849ed749bf209687b19b63fcd06894b36f584884adcd7e2875268e0755f), uint256(0x15f613412ef19eaa2ffeb2d9fdf781e5183cf7d2bb50ecc27576ecdf37d61016));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x231cb6e9ca0bc722cde2564d427aae56b17a82a4c9cf337c0a93625e97a681b3), uint256(0x049297134815f59f7c80d32501159d86aa4502900075bcce024291fe4f02d327));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x09017e845022d5ba60c92a38515258b42e0aaf8fff6f4eff427c5d963e857de0), uint256(0x29a6414aa12d4167961ca7868c4e5a1dc1f34cf66998aa7969755cfc6fb3ce3f));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2cea0373886d2d3d846a204f781af98486b0b348f911b5e87d6088aee51462ca), uint256(0x2a3b7159b27b1d521a74fa4163d7e45d4d8c77b8afe08f44418ec87c0653feb5));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x26edb6957e11901f64461fd0a596058e2b0ccd00653b9ab961ebfc1fd29b9feb), uint256(0x1fbc058e3bf0622c40e8a55e98361bde924ca4e3ae4b1e101926e1517bd93db0));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x09a4c07b8bf0a51d15064a50b0bbc06611456735657d3fa174731ed6eebdd922), uint256(0x03dcaa2db5d38478ff82b8420e8cabd057cb0ddfa8674a83a76536d524076b07));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x186b0d424aa4467d26cf2ae93a8f2d73ef79c4a61b147115f00f4687f03b495c), uint256(0x0163f901fa6d4857ab75d372f0f88556eb01c028fd8f167b8f8a1ebb807dcf38));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x24424b7ba0006aeab431b0ba9ce555eedc41b62217588349fb176a3eac98d63b), uint256(0x0706556686651b1527d73921f907e3006a0d650032f83a26636defa11c7bbab0));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x101fa97a49b017ca0e7a880786a0ffedccb7c35dc2b83e12a72ad1e2852f4e47), uint256(0x284b89f5f47c01320473a6ccebd586f7d08619d03a4e361ddea167c9bfa29026));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x17a5d1001667de9cd48121634a827cd7afd6a523c37420d711e5255894dfdc1a), uint256(0x00931ac4b6f606459a911ae845ff6145138fcbf2fe37fe7f82037f7eb0a4a5aa));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2b91a027739a25622a556e61e99f683a470eef0d8d168d3bcd56ad33c2e73ac3), uint256(0x0f5d529c54227fd00354f818b6eb4d777d20a05faf6cd63540af02bf528b6654));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x29b96e15b92149195b370b986c32eb202b0841dbb0712c72ac6b1f08aa8eeb99), uint256(0x08f1f250cc456355f5437daf8c4ceb5dcc8fa87f6047c852c0dc1cdb209c4c9e));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x0c36544251d27d7dfc579fb6b680773f2b18a2b397602d101b4cb5298fe5a117), uint256(0x0362777fe14d7088e759fe9e875f07730a9c93f99457c0a4fa8c610579bdc374));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x17eb415a041ea9fad21ee0b63fea18da55c93540655c91acaf32dfb5827253b4), uint256(0x255918eea6e83f6aa3276b32133fd614a55d4154a3e5c34c8f89ee40b367409c));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x095370684c9ef2ceaf8e8a180024b8fe89c8f6153276fcbf9af2beadb6aa9c97), uint256(0x09ee6566c6df1bace7f49af989753cad9eb11b71b82089f8f65dbb9417d4617e));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x19861d59ecc60cd7767b32ff193887c7eed66d230d2a4cfda3b651838ddc840f), uint256(0x176cf2b0928157a7fb4e0fde28cf7cf17a12fb8fce1ec600d2ddacb770e056ea));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0169c2ebaed9c036d874e0c16fbb5e6f805617c10d6d1341d91238069ed55115), uint256(0x2a9b16b84c56d3c9e25a6cb587f30fdd3bfd2eda044663b523af16e78fc66dde));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x2745da2ee2e09a677fe1b64ad3799894351d81910d390a429b161b43677b2bf8), uint256(0x18b11dfb369e52d7ffe6a4fe60e38f83d313d3e0c41400bd9300f9a1f6ee0d5e));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x2e910ff4a0f4478bf9be7613a03a4d7db877cc243db78b3c252836edbe6b24f2), uint256(0x09bca0a28ab844960b829a933ab0867136bd3f8ec91cd0b45a298b01cec11827));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0bcd4059535f057f61fa9bceed3b0a29347b5196de43c1ffda7be4ea16de929f), uint256(0x0ae75b291bd70984aeeb5069d645465c16085025fce5910a5d9d0a4254e367e5));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x0f193e77222dfcf6744cedbb7bfa2ffe85f21c1ff1c6a63ea39a21bf84b88baa), uint256(0x06ced4c94f80ccbb6d893d28dce6658fe822021ceffa25702ac061d54b3e8ae2));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x1036bcd10cc0c4467f36db71893fd644cc93c27d8e6ebac7f0d93f036316f94f), uint256(0x09677e0194ba8a606d4ce0841a99d5ea9184516a1b09b350443845d3e548dac9));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x1e3a0861c533c4cbcf955ea31be04de871825e57295370adf445f810b2122014), uint256(0x067ff7b24de1cbabf59416af117284a84962b15660a66909e29e99885d1ae1a4));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x07f6b885ce7bca982a8a045378edf9175f940a9041bbab4b5a0284a586a2476b), uint256(0x272d3aa308d28f89963ff0fabb70c953cccb8642b5b9f87b853eaae303c30c97));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x13c2e533d665d74b00316890079310950792b32590c3f62089b73a55e51d5749), uint256(0x07151509c3f23eb3bb1a6971b33d909800071688268450b85fd1f30ccdc26623));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x024170117a5b94b7cd7202035a20c6a159463fdce67027d062fd69e172a4f8bb), uint256(0x10a19b601147fbffdcb8cf2f7b09aaec90dcda5815a3bfa4df30d346cc8b50de));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x14a9e656b8d817b223e1a951262a5d34bdd78ec4e9cee2fa1dfb9465bc3d56b2), uint256(0x0d0d5a6fb1b858462b7f2792c92ff7f35f1cc49af118045c4b1ca2117b8c327c));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x043f1022480f4c148cf33c6dafb27f0a97ac5290e83f1b78da0328a8630f1264), uint256(0x002171d5af5339b5a1e7da979515b4cccaaae5a339c16ffa7a3432f0a22141f5));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0e9ff0d5936fe18c9e95aa106a579e43f4b440445dc39abbd82b6e5603252338), uint256(0x07a1f4d373ea0500fdd69ac73d6d05df171cc19a5afe32804b96dd2bb73d43d2));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x0c28eed0b95c02279ac75c0f5db2b8e721102c7b1ce4d364e74250d0972f652c), uint256(0x0ca71dfb1a1b29b6bf72c3ee7f534d6aa4496c13236de3ab7d057f77e5708706));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x22e0bf80ac1a3cd09ebf816292b5a3c3be56b6cd7e3ca174b87e19dd22aed111), uint256(0x255e0c4a9d94c44af2ba81a67ecf338068b564394e81cc80703a1084db790b50));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2e8d6706af5e436421ca897765f21ac48fc168a27347d378d83b33df8c381ee7), uint256(0x01f430884236158ad61ce4b66fc852ba6f2f0abea537029b61293f8794c0b244));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0549c9409f811135bdda5eff5f7159a2a69a70343c6cdf5d153f4e72169b4208), uint256(0x0946b47f769a046a215c2c03afcba7e4d6b21100d85c6191ed96528304e6f10f));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x188d0f5b9d89a6e33e88647a1a9f06a661d701e9bf6ca162829bdec3d6e481be), uint256(0x06b51db32d7a1d108ff928e3203f4ee6985c49b819d24409ebfd9b158fe790cc));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2e98ea5b5f7937fa0a07f26f8904802becab4e705c8731310dc018bd2d43d667), uint256(0x03c1addbfc09814366970aaf4b0ff4a61d53beb1333234eaf33175edb4506e1d));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2822149d9ffa53f69430e63e421effb77b4fa112fa45a4982c523f9559dae164), uint256(0x03e0c0165e75feb01c97fb4380d1858bd72fa3c2b88bd44c63bf6bf22de8e368));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x05e4777b8906ae9cf325360a9533d8195902532a800b0ae29d8592726e909881), uint256(0x15ca17bae2c0033d3850f25ace94b7e99e59fce8094858835a75a9928c519788));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x11c0c0aab30e396c048b12e7ba92662fe0535a0909adc90b4ae7d8f2a56d24df), uint256(0x1b5b846d09d3387d32ac3a156032790c9993670a48c97e64484da6656472036d));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x207c1942663ad9081720eec8f713cdec6e1b6de63ea716d986408aa0b79abca8), uint256(0x01c4b8afcf625fa499edf5949508d7434715422f0acc34d92e57972dd18a47bc));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x0fb1c1bd59a6e85162ea2c06c98a4a5d8c17210d8ec1185c9ddf2a5b840ea416), uint256(0x04e962c28bcad1e272fd300a7527b557e9a577d45f5e26ce7938aefce9c28b52));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2dd3d4636edd94f820f577578cc84c869df5dacbd9ffa5a20555e39f89c653fe), uint256(0x2d617422aad43b6b4e2fffda2530ce306da7cea5fdbdd189d0666a9236549d2a));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x04135aec25ade3fcb488698318597f708ddb15f8287417f9766df56788a84f6a), uint256(0x1e344fd61fb5938d6f08002509080e319140bfbfd26c671072a02719002f464e));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x0ad90b4ec93faa1ac0cc03e82b33e8220986c3b0a43f4892b90d7207beb92256), uint256(0x2d46553223dfcd0646eeb12028c29e3f3018b9aae637e83d9f0ecb5c756b536b));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x286906a3fb956deb433db1c85226e70f9e06ab0dd103ac92266d826f1a87c435), uint256(0x1d8eb09ea36d28cdb3bf58b73e4006c01d2b5e4259d4c029a813f02d914acb19));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x04cea17e98ffe5de0670d9e6cd7c0fe7c12887deb1e8e75829dccae9c3f1a022), uint256(0x2b77e775aca3a1a8ebe95c72cce1ac8d91b3c75197025aa9741d16ac62f1ecc0));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x1330fafbf0138a77dc25f4f89fa80317feb4870285a85446d518693db21b4565), uint256(0x208dab5a8d32484f153e86ac12d768713326eaf0992506511f288811046dd950));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x14c8448bdd7b32b9ba5c546390e6d062ef0387c80081fece3b0819b2652113aa), uint256(0x1c36e9e00ca6bad3fd89838ec1498157029951e57c96581bc3e96632a5589e9a));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x13b09c90f55780d2dceab2370c2b26aec938431ee51a94dce61f2c485de6153d), uint256(0x20e3905bf35dcdcd4b18396e0c047a1969c1ccbfac2fc08afefa257ecdfe951f));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x1794ec6005410b2fb1bad8cc4dbc0941a3c23b9df570ea8cf7a5a15fdce83d1d), uint256(0x0fb125b56c2083df5ff6c47261df62b81b5a3d47c9959915f37c27b39057faa3));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x1f1a983f377fc6f4eb2834415c18062aa6c66ab89a4f64c0811c91f4ccd733b3), uint256(0x12d92b040ee2cfe9d373a3c88e53667529f0a12a83cdbad6473a0ed99bb52dcc));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x1f60d54a3479b6f14f2feb6393146b7b6adc96ee27884cfdbcf8cf30c9cc013e), uint256(0x225cef2b3ab14acbba3cb932da237ec5db9a1320adf2decb0d5cc845a1ffc353));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x2e6d741e2f7ee06bef4b0d2f19960346d1b348e99c1e263d71fbddfb5faa2ca2), uint256(0x0f3ca65a51000e6e0511033aa17ae232f83d2c85ee2ce1ca1ded146fb4f4e450));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x0b72ecaee8355ccf99c5c55a7f986447eadf266e7d04c770bc226890c9a0dd4c), uint256(0x2f70a9d34c79b9cb0ab7c2be75eaabc486e842290ac190976cbc5d14a514b442));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x0088c093cb64bc9cb51f88ac7f9194f3e5be7783ff654f75a3870821b6e01683), uint256(0x1753046291f345c0de47776cb2d01631dbe3ce6bb884e2904ea3836d89593299));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x110f99c511535a7ee3df9b267833073ebaa41229aa9cf63557097fd7a1f6e0ae), uint256(0x22beef11cb1eb5a251515ce0f6fc03901b10d09af5a8cbf8542d5fff441b597a));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x293ca130238a8b4b47f7c60b5d4b45d2ac3a4affeb7962b83054061a999b9c0c), uint256(0x00c1db06701e1ab48c2e285f40267b0ade9aa036f5defec91972c2dc9eee675d));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x18891207619b39f42a1cfcb4d1386608e03673815020569093b940dc87bbdbfa), uint256(0x121e88e6a144e525f0d1aa9c903ba50b6ce4ddb40af70730f49fc68edad72e72));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x2684730ed639d889478a4edc5f2e90d5023f0cdbab3b392ffcc1c670635543b6), uint256(0x2c1695dc355f325b2ad9f4e8220770ecb374670e13683c1e82affdd9329cca8c));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x23ab4a89b64b579e3c2517e54b0c5045e9b2fa6e936660ca03713e27a500dc06), uint256(0x303db880d6f5e16df557f4740d20290cb845045a92f7c9e8c4407595f8139d6f));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x0793cc74ddec12f9a27e1f002f25c3d34ff2bedb1e16735ce838360c4a9b4457), uint256(0x193c254aba184f81f2a9967a7386a30adb16fae839dca8eec7fea526c41a6302));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x13cb7756f9f358efc4d068811ce9838f2ae797a26893938ae5581bea5ffb4790), uint256(0x2c0480398a95d68055884b832119944f0b573a005743ddc5dcf79b0d1b2e34c8));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x26c7f3556556960c4d3d98824ef9d31dff3a6772cc10f49e2e193367a33b3eb0), uint256(0x0707ff94b1b295acb1e59ef50037372642811e899830b20aff7c56553a4c2595));
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
            Proof memory proof, uint[77] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](77);
        
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
