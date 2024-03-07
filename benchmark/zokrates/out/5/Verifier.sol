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
        vk.alpha = Pairing.G1Point(uint256(0x0b7768497feeb059055d229038eece2f20016964805582eed3961fab344d9411), uint256(0x02aebeac6d9967f43246c511c1c894f61bd1df647696f96516252018bfb8fc18));
        vk.beta = Pairing.G2Point([uint256(0x0cafcc3cd3c44513f4fb5f3bf9568b39ce92f0b49457151122f8b248833d6e73), uint256(0x0a1cb76e73d1ae94ee8e5e81a2bd031ed5dd3bd01496d3c33409c731eaa5bc8a)], [uint256(0x15055a9ed137256720fc7ec5a6457e7b333691d04ccf541825832e957483e2de), uint256(0x08b1d3367f2a9a2a59d0d2ff9c52e7049b398ad76a85d16da57b2544653faa3e)]);
        vk.gamma = Pairing.G2Point([uint256(0x2095d77470129d292af31590fbb1e599b60c8782f903ef601277ec51f4bae0ff), uint256(0x204a93beb8a9fcb589aeb6ccfa79c3383d0816c39c41e07994cb7d278e994866)], [uint256(0x0e3dda9af27020f426b2a12dc0a011a91aaa8b5de7bbbfa48f10dc6878b718e0), uint256(0x25e79fdbca729ee8afc5cfe1ee56606f6233fdc73d6cbeb1c6b2d2a272e253c7)]);
        vk.delta = Pairing.G2Point([uint256(0x023f86c776857930c9af00e5b147887b58844d212a4e81b0da112b12ded64dd6), uint256(0x2c209ceeb48cb975e4f6d8ca42d9ce3bb6f8c41165effbeeffb3d0d1d29a6810)], [uint256(0x22f3d68d58855c7c7e85d0cfa19b36ad9940ac2ba85eb6a20ab40bbb9b885917), uint256(0x0cbab3e8b5233729d9f9d0fd556a4008ae86d4432a4d47f2c1092ac761c637c0)]);
        vk.gamma_abc = new Pairing.G1Point[](97);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0545c51af1496921e1b43f971240af9f782377e9ea8d53819833cbff3fa8a424), uint256(0x2a851751a220dbdd827df14cca25b2f966bf43885dc3ef8ef91140c74d37c8a2));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0001dc8d512ee726b872227c6770cc1a132af61dc342f96035534303061b52fb), uint256(0x2e7a6c76b88e96493662252ef6d6565a879f1072ac88117c3e2e154a48e43294));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x223afb7c56d88afceb155e6a4eafe3198d91edf5be8fa4494c1ec371ee5ab7f6), uint256(0x0e78e786791d281ebfca1be7bf0451aed767170ca5e8cfafed4448f709f7222b));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2f29b017f1a8d4c76fb6cd952a984693aedde047d912eeae612e50eae3525b50), uint256(0x2ff59ac030d34bcd98a45ab6a96a0aa35cd4317a5d01e62e7e32038b43dbd39b));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0f7a601b71b4558ecb707a1f53cf3a5eb9a89e6173685c5d74a0dce69030486f), uint256(0x1ac5f9a2cd6901954b74ae70766ab332b79db42ab0e71bfea7ca2540fd53abbe));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1da2049edc1e8134130162fa01dd39ba99ab946c34e6e01546cbd160675bb94e), uint256(0x17e3af31bfefe3b4d6753e0c380d9c1dac655e1de1765df154f4609927db5536));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0244cb4e2051e99a901d5a170c354206b307168b8b4f8b18751f9c8b69c24b55), uint256(0x133d83bd9ff13a6525d65a5c97f16e521e1ef05d27bbafaad246ecf1b6c784c9));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2ff0a5729fb7967ce130e2ed65d27d5094a6dea05f11b154dd5bd10d5442fd6d), uint256(0x2fae249b029f9a90df06ae4e5244578484ae7e3efb52c8e2fc18692508e17af9));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x084b4c22944ad5effb7c69a1ccc77be155e1e7810cc1cddf16f35f6cf9dea64c), uint256(0x0b95ac5d2f1305535c0e7e60ce85935008dd37c7f16184505fbb854893b92758));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0804797186578e39e0ad094d6ba9663d24b4bc6c6f1feb3ecb23bcaf484e3142), uint256(0x2ff7192f14677ec01877a012f29d25462da48b04c87c4444ca5d972030252870));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2fb85030b92852d1f384dd8a6422c951c54420ea761b259bc4513cd680c1b4c1), uint256(0x269f0781dd929618636632d5f2382a365cf887ac762b4157ecd1974d0790b730));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x3019d4edf8352b6c01a395b123fd4857763d19f88df87293050e8d4ce7033f4d), uint256(0x0517acb4661cdd17eac60b778cc87e2e6ad4e8e0e4a464c891962ab400143214));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1bf3246adb263dd8b961fe26b6072906cac989335dee97c56dbad5df9c7f2927), uint256(0x09791924b3e9e2644bcd0bcb43aa0e517a81359c7cf6b874eeb62c5adffd162d));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x17e2169544838ebac54c67b61d696cad6f31db2288485ab7f14176851c1ee1fe), uint256(0x21d73036cbb6116936af59b25ca6956bb9e4004d82941a065e058b02a34e3bc4));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0336165aeae0222044cd1f46a21863df42341b5f6306457bcd3e2053558e219c), uint256(0x1545ef842940c40fc2176fefdfa98d7f2ec8b9b9f7c720161e1ea76dc69468e6));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2fd178138f0710ab992c50bf36fba178d352d55c308a74bdff7bd9d1528047c5), uint256(0x28f27265e2ee5563b1cd1ae99d784a06a4b27962eba61e803eb878c4fa421684));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x16209b1f9081748a49c242377e9c5567b8ea52670d3860b94cd93b7349597a73), uint256(0x1b3e5e1982c3527912a371b048c2ccea042fe97c95a47a49b00a17abbe8bdef2));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x14b75360af8a66fb7233308988d661520ef976f48097d0b9238f31c65e79debc), uint256(0x30183aec88023bc66923e646344ba9488f236e14fb511229c1edf68b50dca859));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x149fbf5b6093b8972435d5b4a9f2cec93bc0df44dd0146e48abdaca58802d164), uint256(0x25a775475f4ffb7586647c0fa343a2abfbb7aeb531acb7fbc5913295be4325c6));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x00ba79d526ed94b56066e697e271af73891e9f9e9e602474e6aa2c3b8761804c), uint256(0x020e5bde8d14390d16fa00855154b4cb6a8b4d04c92714835aa86e19c67ea175));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x25146d05d0f90fc52ef29d4862b816b7582e3d1654bf542aaf541852ccd1d55a), uint256(0x249fca17db834c24aae13d34a5e98a8a4a849b77559d66eacc3b7bc8678781ec));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x27328bf2ce627c8781032f52622d11b76c53c807d422bf67436d21ac206836bc), uint256(0x28503f6dce008f15fb0a7726b624c8b0c4b568d7865ed7b1441379e5aa576b30));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x08884eb48b9e901f43eafca57039d8d8605c85c9abed525e8aea09cf041e47b3), uint256(0x10501d496f3f2657b8d8f6088cd129220d7e8b04d246c52989117ce5f522aabf));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x026ec76cdecc8cdd5e8ae96366d94c88f037591e32089694ea54cfbe6659a97c), uint256(0x09c7f792d9d35ec385d575207541d3cfbafae906b4bf5108166c097b19cf9568));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x228dcf8b0fcbed1e38a07ba564892ad380bc547f94ed6be5070fd42a0cfd7cb2), uint256(0x1db471232b30b5bb9b8b30c94562a78d0041bb5d7c7edfa0aa26685a700e35f6));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x279da77561c3cd3240ee56e93479f5582c74edee4cff3b5aa834035a65d6563d), uint256(0x0cbe77c90d149e7ed0a8afc8b891f36a7b084f7e943def87d93ff27a104f738e));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x03662129da43d03c699cdedb3d1929e563484a8b9f020f0319fa25bb551a857e), uint256(0x27c612356284e3d2d81697305eec822f9f5a67eaa65de436a775e2314b6731d2));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x15f436accb287bfbc73a7385483d4b54463884b770c3c637f35e53e6ab580fa1), uint256(0x148c760aea0d3542458eb9486254b02064274cd793a60a65fbfde2b64bbb5291));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x2ae0b8294ce03ddb554bbfa7f881f8f04b294b173047135ff57a96fbf5f7c415), uint256(0x10d53289d0ec79dd6fbbe2ae075913a72c8069f18f330d4e6aeaa10d8eb16d58));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x22cc3fc2a6d5b23f0e5e9381c81ddf0a129391905918ffb70d8af56e42c8899c), uint256(0x178707566a70e07f3f4f06ea3179bdc03cd53519988bc517f8c30ea5c5c3926b));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1d7016e5fb486792d411841087bc2edc7047032ec25095db96716c21775b8b12), uint256(0x1c74e829d1415159efc4cdb5156a093eb7ef997108c748fe254ddf9d93cfd2c2));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x16ad445c438e680fe092f6e2bdd30c00b1ad9e8821db95879c5840cfee126027), uint256(0x2d4190e150735c5ad4a3bcf3cf6d4e376f022c8c548d7d44c44243f2442d87e2));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0af9c47052f9821c8d71c2cccb903f1e8e3baf432af30ee4d3cf12433c3f4278), uint256(0x06c7f044925f821a8096f0fb20e6b4092e37c7782f26b705a135031418f3a5a4));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x187f803cc6783b2d868f051f632945c53ae8790f854df5d091bd24bb9a9d20aa), uint256(0x1b11727cad14285057df6137653c789673ad7d23f95e1998541c972946c96427));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x1ddbc989110960f6707ba118d6a731db753eb192d2c88c9a8dff1d885d00dec0), uint256(0x0006b8b36bbb4057984042bf0c225152a1a6b15f17b354c78a52b5aeab651f16));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0effdf64fa4d301fd430e77e92add2906be32291e759519dc025cd5d0296c18b), uint256(0x0aeda9e7e40310cbc3da1a9ec44afe8c2193c98560e150ff6ba8e4add52a1409));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x26277806aa29e4009c5a261c33845613064b33905686546c49d08bcd884cc2f9), uint256(0x0f65eb9bf22d95b5fcd30a13914237cfc3f3ec9b8fa6044db7e279e15a83c82b));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x22e4a0f1f4a1cf0ac4b71e1d5cdd88c4048b1014e27c77db977563ab292e882c), uint256(0x12e1373fa92adef0b683766a3f588a64968fa6c0f00d85c364d6392c6c4e49e5));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0d734dd4a6828a550e830a2671d8e7f35c59f2368d529870fa5d7d64f9c057e1), uint256(0x2283e16b232cb167b554cf1eac39121d589a371e6152c2a8ca3b8f5975e07708));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0aad773640f0f3520aab82fbe5103ff4c31b225234fe35f0c081f462ea4e4ee4), uint256(0x1aeac4ad6aee9ad1c83f60d11784659ee2575dc311329c6737275701fa6bf46b));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2bb56bc1138b8ea1fe260a97e075164811a0a4343fadb6344e4c7cf20c1f02c2), uint256(0x190076eed96f19df5e6a04c6299ff15943a946f563dc4f6665d64a565c1e5f5a));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0cf07ec7a4984c3a11373eace481691cbc12751b52b845d2e09d8d2a57edfa25), uint256(0x051539835083f33f522ee52cc3d7502f03261fc7e621d57c6d47334877863569));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0406cb748c54aff104e1d492ab94b8811077061293293313ec0f64ac68070667), uint256(0x2a959fb6446b03c474d32c9a1d161823d0999194494f96f6a7f29089e38eca03));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1789bfcaee30d43fe2ca1b2694601927b320a07e3ae64624245a8b91d97d6571), uint256(0x1a9a40568ba016c0c2663a50ba4eb6dbf58ec29653dda152aa61a2132296a4e7));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0cd373f1e421f244bbd87591a6381a737306ebabba0b259e055d32177b19b813), uint256(0x22d0cd75dceffbdcbf01caf38df6163f7061a14dec6fc484a792fb6f0d573035));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2d0fa25a411668734a67b4186c8215360b4e1e922ce3d29a87775f3e540dae49), uint256(0x26361f0b67804b7653108f93decc7ce5cc8d6fc3c3f25e5ffc43d5b7f98315f4));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x047d84c9a46d962f29e7ba94e5b445bfc93cec35bae07e57ea8fdfeed241268b), uint256(0x14238709a43118b40a2cd3114c381dca1ddf8e5f79de081191c617af11c19232));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x07b95a2523582c980dc84f14a32e63491c4e690364ee3819ba8c92558f2ee531), uint256(0x002b7f50310192d2951be97a742a83194c0dab3162ab739bedc50e19d7410b52));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x06a52d702043e210ffa3ce1d6a370bbf0ea75c7e47720fb40f52a2aac79e6f70), uint256(0x09a25496fe3da4e352cb7cbdb0da6efb60772b392d3d8623dccc98189f4eddda));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x2aaeefe0b1e29dba53112410791c448391c732f3b9b71b7eaacaba800b3cfeca), uint256(0x2e5eee3a57e87800423bb3b63eed694791702f0fc38a1d7a7c0dbae1e44d1c06));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x18471428507756e9b2be453a950ed3f382da0c0a27ba865e92739d9791f06199), uint256(0x191841903a5d1869eccd8b3d5fcd3614e76118ddab65fa9952c11c901564cf89));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x0935f1b00032450d0c0afebfef35d30241b03becf6c081b2154ac15ec11da117), uint256(0x1567e450aa8461bab9c984fa2bd4b90ca6e2213ed3482f47b00621c9505130d8));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x21ecf73e0f539b2002703ab335bbba2ef847964a76013e58c2a78b071e6cde3c), uint256(0x1ca49b733e75989a4dd5acea34c318847513d857bc528941f18648d843f05f79));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x249634cd5b84a55c5d60ed6cf07c988dc8f6733dce9a27b256f4b25dfe678fe6), uint256(0x1252a3b6c49676f9ad189a179d278cb9f8de770ead8d9257604bd0ffaa37bd3d));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x2f86ed1d67414c8095108eefd16d5b3baba3274206f65d3c992ea5d955432e08), uint256(0x212d85d319d00281113b864b58c259ba52a84f7be400a0ac036ae2e0a1ed4cd9));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x02dd4d7e6f48b7680e0a9cd225c2ac7c4d925c4992e4fc8538963e56651482f5), uint256(0x2bdb3d079cd402969a5762ef3e009d005c8e18e8506754a05e41af11b9c09543));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x261fe161db302ba13da03b415b813afcc992032987a86ab7214e0c2dbbf4c9e1), uint256(0x0ec0c058695883dd2ebd61b88ceb266f4fe13b2bc67b9e7f32911a2198b751fb));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x0ead775833b786413ff55b8f946ab1c36cfdf5fbf9f7e2e663ef4d0874f25967), uint256(0x1f2f9474ae58ac0b5a19d3518fecff9fb9b687cc5a26e1bb110a634369df61e0));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x00e0134d372b564f88f3ada6cfcd2c92fcec000d83db6683d6e738670b3fd34f), uint256(0x2377af29a1a95cd39caf5c8770f445baebb5cd7c50fe658ce1fffbda130c2dca));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x289e6f931c5d6d981a49cae0fe354f6dba91db63c7aff2afda9f17acf13a39cd), uint256(0x11c5c979a68f295a7d1871f345c32d91733aab61c4a162d0d8d2dc5aafd25200));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x2cbb7fecec81c462655e4946af7239c1c8634c668c152ef0caf3fc84bb64f54d), uint256(0x2e30b96f0791c8426e11b8947ba7677fc0d8a8bc86fbb40eee402c847cb4a21a));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x148ce4f63d7f30000ed0751d3bbe656c086a76d3e149878fd75c341b6305b127), uint256(0x09ba30a8d1da4d85722e8044ec3598e14bb3d00dfcc2c7a6db0bf59eebc9108e));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x268e162d153284b22b1e352d9f74ce81e0568d4889e402fc41f20befc7d317cd), uint256(0x2cdaf31c930cbdf6b36713ab4c2ac308781512970c2995f0f6aad8f899aad61f));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x055e7164b63f84ff16efa389aef88ffbeae67f877a2ec4eac45eff4f6db03741), uint256(0x21ce4b0c2828e8fdf37817512476b1a57b99c0dc82253febf809eceeb2f2bf0a));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x0d42ed6cde6a13d86a4bf4ebf30db816d740779f68d8c668a7588194ba939b66), uint256(0x1363b7f72c81a52f98cdef25f61189d7337fb3f01d7f884d7b9c5d68153ad4d4));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x201995db8a6737abb13c6beb6bc4c0749db58e02dcc673091762558ed5f4f215), uint256(0x157f489567ddf3170bf047b34894044bd7e84c76f3b3dbfb135955595b5d6b66));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x1350cc9b3438b3f526494846dedbdac1a9fc050cd920181cd84e4a645f5c9347), uint256(0x0cd180c68ce98349211af183c16daf733307a9538fd741363bde6fa7cfb7828f));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x261e771b557415f91cfdaf9dfec197ca07339a234ed6765e18c07ea8f978bcd8), uint256(0x24a2fdab2a5ea06bed14ccb33cd06692d4bd99ae5aedb20999f1354e18a98e92));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x2b2196289121830e52deef8a8f5c63737a9fcb18125a29d009fcb4d2a2a60114), uint256(0x292ed1f620d59d9817afd0b1f1427e26b8f9eaf28a456f5bc08761dd3a38e4b6));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x1cef95685994c5b7bff50b39146786e0259b99e6655063f7eab0f9231f8fa19f), uint256(0x20fbed6230e49928fd2d1449c0a5144bfca8fbf9a623b89799ada20100aa4ed5));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x239a7953122c51285c7ede8a423bc70c66aa8081562bdd20d27472f05e835c22), uint256(0x17fd1db05e1efea12618382c179e3ea456e8824eccc30dfab14aa19eb013580e));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x1015e449c426806a7c2b79f99520514d2f36a3afa3abb7cd93bfd4361bf6aa93), uint256(0x1a05249f2c5c4498495911abb527355f7866d76ddbe07c4fdb4f471d55aa0dd7));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x14aaa05f92a1368583f2d5b1e08ddda256e7dbf5d1e4e50e1f0e858cf7f8317a), uint256(0x0b40a545a472a8e83610f95cf650c85e88002c6ba9aed23d1f7fe73cf4f7701e));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x01608885cf08d1980e3c51dbb1328138da559661e25ac077d80aedf559e805b7), uint256(0x2b4163455477ee6cabffe3d27f28decb87bd71b918c199b453513984d19bb04e));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x264cf135a45150cec14a64c469707e630afecb8e408eb137f4ed005f5f7ddfd5), uint256(0x0a4c2565b6f546e3a6e9eb743e62e66575210d5677463fc98a3f6513b6759e7c));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x2d04b14a1761ffb0ed64ae23bdace448bd4e157a62f91eb36d5c0ddc78135d89), uint256(0x07c12a84f54d63322b033912ce659b33a330d5d782c0fcee9b9b24b35eb99321));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x0f5e9edd04b3c41a225a348904edd37d01e8a487c76cd271222942176b3066b8), uint256(0x0bd1a3b008e565d1e13560d5d52bedcf57564751f19d484ed3a9a9aed6c7cdfa));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x03a7b27e9f23b25bc239090960e28fcabe9013278063649f32606fe92560bccf), uint256(0x0bff5e744c817df53e829d2a1720ab31968d8d61728ac5816f815ca7b3763524));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x1cc69872ae6c50e38dbab93bd5c000bf17bc1ff6a5b1307fae93ec95222845e3), uint256(0x24860955c44e1a30972754bdbc9e80bc2a0a47e326b72d4be6f2f9730ea9ea6f));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x2cef4d5db047ca7de2592c584cb478acc0603b17a8fdc68f47506e2a9857d140), uint256(0x1302c82736cc03dd8e1076d5230e7977e2c9e581b5339b4412ec03e8763ab843));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x304073e1ef3345e82dfc1f1b43fb3546db88e64663acbef0ffbe77fb39c4d082), uint256(0x1c6a61b8b415c9d7f8ff41613940c884ab9ed7b2225a8a5352ec959e97cc3ad4));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x1d739afa8e5c97ca9284d2365f3919477c7742c80f84dde5af4c05272f1f22db), uint256(0x2ad1d3eb8d7c61a5ec166f983dc70ee4e53f6ccd885a15b80a074fad7ecfe3f2));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x04cfdac5fae615957c524a1ab873a94c0cd1ea24796d3a674b3eb8fd45ff7b5e), uint256(0x075d0b1026e2602cca1c2bc65cb9b0e85374d4d643845fbd2f80f39aa8e09f64));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x19d3bd688cf5e4c0caab1229f08e05051c28f8cc6a458f8b56229e5ee2c43f33), uint256(0x2657d35fc912a3a642a7c10f90d283a93690a2ea1dac023e39b21e69ccd46ac8));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x26047b8313614f07b1ad4350946ff275e8f385e0dd085b956fde4eb842525b07), uint256(0x222b176c44345d08c84c17623ad94d10ee564ad7c193b16c4472581ba371c34a));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x0691d9ffdcb3d9f75a33201a13f269f41b014cf2e0b897df29608399896261fb), uint256(0x28f4fcce0dfc119651e60a618a6900b5831cd94c6007c98ec1ed5730cf86ffdf));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x06124594305674467ec2ab60ea8caa1457eafb31985c27c2b81d243110a52614), uint256(0x2142ced2f69c1065df91c85f41f180769943c567c068dd104da8f0c8a723aae1));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x139a5d952c816d664bff7dca7b2043c33e35c1495715511791226852cd2adcaa), uint256(0x038d450f2b211d0e27d1bc480bc470d9d87e37af6e193a592284f61409c25693));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x285500e438021bffcff3ce16b00af2acf0007daba9e33ae3dccd8850566545b5), uint256(0x2c516b63e8f6509f834f7e3b05ceb6adba9d736d56133d87fc40df110dca0c39));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x159fd4e2f125ec630a3e211efeb60b68ed5c9c0667c7b378fa37265d541db033), uint256(0x091481011601967d5efff41f0255e932e6de69d2a202fbe1542fbd23ddc94fdb));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x1df36085009f602895471ece3f5a1a288a77d158c0fee2bd0e7e4424ddb0e5c3), uint256(0x1b3ea995305c2cd5c7fa040b97051d7902d270b527d5e72afdf90cfc6cf43e9a));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x13cfed20a6f500b2e89de0381840d9b0b62cc2a3d513dd20d87dab365621fb1e), uint256(0x02786276d577665be2e1b406d8e400fe93e412f7e66dbf2b92963599258dfa95));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x0d9582342497dd4d31101c186937eb0f093c1ac4fd90ccbc5dbf1f895d3c3ea0), uint256(0x257725524ce0238be636a9101b2aa4f1673b9add1f125c0a13038fe0abf30996));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x2795b46659087e9ea9ed8f2fda3009a46a15cb3ae1b9b9c1a593d0cab2bc36cd), uint256(0x2360ca5ba19fb7de0d2426a222d662adcae0525b7b169967a3b107071d359026));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x0b0674f52556c06e5a76ace778a26ef1108a82c21ac6e648346c318d51a603cd), uint256(0x02625300c534a379a90f63983634cdb76912504706950390e30272dfbc0c7a20));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x17a9487416653de7d78a08e94bf5ef51fd6930237e4e924da82338f60d20d8cd), uint256(0x11f096dccce1a85be33b5e8870be5eaea1a6ea22d2094a8f89672a4e9de15033));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x22693c5c52619cd26245f9b56c287aa9117d239f649af01c6040c88f49464330), uint256(0x240243be75c24d245f20d7f15fbe9bf81dc89d0328941db8da82185901e8ffa5));
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
