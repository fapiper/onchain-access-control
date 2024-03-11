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
        vk.alpha = Pairing.G1Point(uint256(0x2f32d4b0a276e7b5e29fc1039f384689177440f72062dbc4f94345bfa4bc7708), uint256(0x18514e540a7040640eb5de2079422f22f07efb66160846ecee5ab616810673b0));
        vk.beta = Pairing.G2Point([uint256(0x085731763efc8619bce6f01454996157dbab86dd107f5070d05712d360a96bb2), uint256(0x2f4c13340c9ccfa01024175dc3cde9c9ec74cb5d18cfd63e10b689ad9155a884)], [uint256(0x067271a41f993c745b1c9830df7bba1d52d580d27f0067e179a951d7db551334), uint256(0x1956d79bbb1366f1261c9e7ef94aa9a9368df503883248bc96cf1533b29e2350)]);
        vk.gamma = Pairing.G2Point([uint256(0x2928e6f8d386beaf4fc52c8b2daaf61e1456f99d9668f411595dac4bff41d0a5), uint256(0x1d41bfaba418b8d48c137c430534572f395ed258e862fb0430f7f2063d5c26aa)], [uint256(0x1c0585b3c46fea1f17ceaf1be1e416edf71378b3683b8d5090fa7d60a3432c4c), uint256(0x0fd81e68d076b939d3d35f642d8289abbe66359a30d438a5488ce43643adae89)]);
        vk.delta = Pairing.G2Point([uint256(0x23b07dbd054d188f4278c9b0a463663d6a63dad2af8dc2865d47ad8dad315739), uint256(0x0d8cfb0a92f310818368ae44e33889f423852a58439c8f5ac7351b8e05dbb7e5)], [uint256(0x1d5aff0a2842188e6d99631364bb8152d7ae083e05569ecbd75e687fd8f62fa3), uint256(0x2c3203701213046cdb6edca416db828792bc2bbd56cce3b3cd50b12e020a0631)]);
        vk.gamma_abc = new Pairing.G1Point[](78);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2f734c5345aa6e8a282303b17d37187dcb17ca9c5fcf8053c7d47d5e159676ee), uint256(0x1b7f3479a1c846a9c3c01c4236d3e1a09682cab30588bab24cedb78d54112472));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x09191a56cb816702fbe36b9285d1962d6e897c205fffe673570e8156835032fe), uint256(0x0d29e46202df9fdce2f4c15cf88720f26d4fd421c88e6452337c4d9690679dbb));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x04264778ccc6d03f3f628fd530fd2b398042b0d739e35b721469009d005c61e4), uint256(0x0da6b86bd8551f1feeec0052c9cc72e12322f131b94eb51c5649278999e82622));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x21a387bd4e8f59d7f4c8a60f23a2f647bce2eb22f4f1031a11e7e174a25afb8b), uint256(0x2092ac88a39cb72233177d46b7f137f65b9f6bcea27b4d29970a2842ea97ac70));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2d7beee1d0456a69f662c25acc13c4ddd5457cb5980beb076ab20c3f62641a19), uint256(0x2066a402c72bad3387d04ab61ffc6c1fcffcf8b50e0730af73d4d0684e25e2af));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0e72f5c64150a65d1670172758c3319feb17c87d71d9227275cdca3544078dd1), uint256(0x13b026a9cbfa6f2bcb6b1af82d894fb2e122de2d974d1e1dd00c5556735dee15));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1f4b7e64895e3e726fd2934f1d98a759d67c46f103a1853ce06fa71ef09f20a3), uint256(0x1b93a6fa000e27795ffe0caca71d7c0aecff8e5178fdb38b1a1205ce8ba7306e));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x06452aa3c76d437e4076d008f26afa37e2fb76720d163766a564e73cc5caa47c), uint256(0x02879dd4facae5382491a0bb299f1c9f9220dd56671a17e97b50088b068da7a3));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x15b3d6f0eb005134a449f66b0770376650348ec4051afd7721f75023ab155c92), uint256(0x0e09d64e00eba5e7b6fbf213925284f5163d7fc1cb9c1d956d149ced4645c5f1));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x22af0d832471063aebc05b1340630848d865f83777e1d77ce5c3982113fc7cbe), uint256(0x0f01282a4dce142495ef7357d5b195fbef9477269ac7f4a45755fd55c527013f));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1cb477c9aedef9274a23e11a23147ca7c09d6174514ba647d12795aee142ecfc), uint256(0x242400e31f51300bcdd50afccfa197ae0e2a1c45e6673ee32bfc5a97e7935bf6));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x27e710e6d506a1e9270120a8769728b1c1074e99a2d1ea48652eb6ae2cf83e7d), uint256(0x204f239069a3e6c9a32f5e868c71c1e342fcda7d7166dad146d441a3b358bb0e));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0f046ac8ef001d94d751c280d9720095425ff3ec0cd18133b592b6a859ec5fb8), uint256(0x2bb1a16d04642ef9d4b272a742517a8bf9354c05c21e4a2ed12a9b12a4cd3b84));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x108d7a7f4ce521dff813361825cb2777688cd991ff9a4b716ae346d5b560c4f1), uint256(0x2ac439e67f87a1de2bf07f9c38998ef7bc3974941647fc1fa02a6abe7be4ad6f));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x03cfeabe970bed7dfb7c11ea3d3e55a711eaa6a56917625309fc0ff229e25918), uint256(0x13b8e11e2f3f7ab6efd600646ffdc9a861fa04dc71a43d5b3aaa870f34d8adc9));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x28b67f48ca805c47cd1a5a153b69d17fb26a7d97071028b1780f9f3b1936ae25), uint256(0x0dd13438ba261d09a57b4bd50f1b502197a0931df451f4e1226ea4b1dbeea7ce));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2b7793a5fb04e6cb758db59cea747369d1ca549578126d6602e7b330be35a454), uint256(0x14b23689a2323873746bb5f9053d44ae350c97afec555326db25aa751bcb4094));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2f52408357e2abcceb94a3d468f71ecd226862d9eab5312969bb62e796f658c6), uint256(0x137f800cdaf935644635e831c2116029429148088e934b38d19069c23fb53831));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x244bae93de6cdf4e37b94d73c720cf461474f36684b952ee539593190f2dba83), uint256(0x015f8feb7e9220c18f55ee90871e96e32d112c70226e9e860d32956c6349c8fe));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x09104970a7a9882c97a74a90469cbdebcb36338dbe48c0772661843d6f3ea518), uint256(0x2711e79590f6784a1ef0b7e6f8ee1c0426244edd5704eb0d815dd09faa7dd92d));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0e9bc2ae5c5e600257c94da8a41642fb783d61296769c57aed6e09b803c2f21e), uint256(0x2fc6cedc4a04e8e798686ba67f6ed0aae323068d5dd00fe0a07fbd032e8ce11b));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x042dc2a2cb3928bb6fe7e3dfe69a0d415136509e1586d95c016c499587ab8aa8), uint256(0x16f345f9a4d8f4a90e243aaf999b297f4026838bee275a11b4249525b5724267));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x26cda0c41d8b044f2065f6c5e835212010467286fa62edbd04640b1c09219bcb), uint256(0x26a4cbf7153896fd5d136f1ee274b99dfd405133640ac66bb9c7e1c71ab991a0));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x27a65fb6edeb20576b5a556e915d10ca37b0b1ece7ca7bc96749599c30bc7281), uint256(0x00e132417cf5c55326b3c6edbdbe65843dbf1fc0b352eeb583916155b1a06267));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x122591077338dc3ebc1a965f2ca3d0aa0f14b53313c5f1b0db7a97811d7ded96), uint256(0x0e2597107c483f01a4f6469db2f15f2344df9cc49d0dd77fd21d541ba3249d08));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x20ec23a1b705ba2c40c53bd9a4b860fb0641b584782352b608c0ab86f2bd1256), uint256(0x1d97373d38908f2accc21f6c94d8f2938f6a25f4b44971c6e28d3219443d9a1e));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0896ab59550d8ec3889a70a10c18138adfb231b3b01b1e5b7134aa7aa30a68a4), uint256(0x04437947bcfdc9f0490894d5737bf64f1fd6760cddf4bb3bf7ad20c7ca787fb0));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2f1e41a9773e10c36872b5ca70dd682c1e826708160f3ec5e7119d92ab9c1eae), uint256(0x0bf5d62ec88699502da6b84c1be4269469d8d3b7acf98e7b797873ac1abc772b));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x181f11d4cc1884bfbc5bc16e91af62eed7a56ea40ea5c3eddbaf0b9f8e971bf7), uint256(0x069e12b52041924c201bdcdea203267ae40e46ae669aaad499cdd72a990ce483));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x290066a896a2d3600583d698c8381186e93c01698ac46aa3fef4d88746b3b732), uint256(0x2d1f49b99dcf417ec8f5a9ad6f8c14032d6cb881e1a5de184b2e70bc8e1164d7));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0dba53b5dda7264508e312f13fa51470b001dbaa54a26ba980eee05f6c6b5589), uint256(0x0bec5010d6208aa12835edc6ab9b0d105becb80fa83902e6ff0de7f9931cd6ff));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x04857dbc6096186950472f9f5dcf82339bd0951b192bff240e9b2e085081b8c5), uint256(0x0c8c037cdca34337acf21ced8833d4162b974275f43c625b47ff83a413e5f87f));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2466b7b043948d5623e695ac07334033002dc7c3a7295d51cca2c1005fbd334f), uint256(0x1949ff95e200caa0e0931bb494bf2bcdae11188795086698bb58f765cb65ddb8));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x07301de29ddeabca82f9721c94cc3f5acda6419d33583f54a9d39b7412b78086), uint256(0x2ff8f31996cda811681105c426992439df0e8151b6a0809bca721b5827d3af0e));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0366ed452db717fad9e2cfb3b1ae0342ce2540f15c22b22bf0220d9740f1fc4a), uint256(0x0103b928586a985de2a5043ecf7c4306f4d55b19fb0d77b1243e8695a6c34c60));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0ebe911d88dcb5beb3be65a770e08e38d271e025c7b27ceb5fc7e9b25e4f2886), uint256(0x0c578a6550b8030780c5e329200164c275b9e7c596106f00534ae23f3bc357f9));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x22efbb6234bf5ddae2635bd8330db588adae7380ab20dde464e1ef7b064fff5b), uint256(0x1279c529dffe9f0b25577e85cc954d232e9a4963f0c46cd10df1bb36045db6fe));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0970469da7126979751bee83c1d4bf88db7cef8e6f979b5b9aaf5c8939fe98c8), uint256(0x2b92e56cf5ac5e48c50c86f3c938e21c0fd7cac91427761a736a89b061293583));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x07c5c99218dd8aaa979bb688f0f6872824f58cec33131c75623215e9abe4e251), uint256(0x0c1d61e1b29ee80d7a0daacb38558f1dd16261b054b6a0d37d9e71322663db83));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x2235eb1c385772eee8246d0ef1371fc383589e9e8cadc1eab3dc87c617a6edeb), uint256(0x04c87345bc00495a2de1c1f55bf12d3308ed4ef672972c91a0bdadf175960043));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x143dc07325f0ca6f3a3de6f6e0addf11d03453a7460caf5ff2c1cfb8c934f8de), uint256(0x068d284fd5d3d0f0198b93283ec545e076a14b7f47acbee9a6a30c0a0dd6c900));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0a6cf889e31e2b58e2e73d25e945fb001cda990f4dc4eaef4c1e34467025aa01), uint256(0x09acd3c4d722b629b7bbb795de2cbf9089bf5d984f74c6d779c15aace81f6bc0));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x2249f867a3fe037bc041757f7d9687320c1c3ffe63927342a646cee72093c9dc), uint256(0x1e5c5ef69710385373fd843372491b4ea2f85267e0026293c4858e8698c9d526));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x0d99de4ac475b6ed86b16f651eb14bdaa46dd67be135cef6d2b6b8828b1f3ba6), uint256(0x27e256788b554968e41c09046e7dadfc33ea9210d1d348206eca408ff337cbdf));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x1dad0094f069fe3823e5fd926bac974a43be02a607db9ec60a485a4c7f1024fb), uint256(0x002713b15645de6988a50db20d451b61bbcd05c46aad62e0df7b827eed0e8b5d));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x0588583338a117e510d1ad34d266bb1a6576df2f5740901fb11f076991650704), uint256(0x01cb93f199d0740f033e6adb55ecd36fc541a9b25677c2826ea6b0eb2c5428a7));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x11f36a6921e563ba2ebeababf17a0cd8b68e4eaa437a2bd462c8f8726d3f6bb5), uint256(0x25e13495749054777652db9b64d96754089e2f87372ba1174077679e64a722bf));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x0794e0fd439727f3c5badf3e8ee507d904b63e164e95d70e6a3422af0bcfbb24), uint256(0x1747166eed8f66567ca267fef6432a303a081253c7f1c5d8d6b26c3fc55e2e07));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x28fa58f8c1ed9ebb3cea93f5e79ee730af7a213f9ee8f84bb6ee542f9e6a631e), uint256(0x2b23f7eb2f9c6a0ab899ddcd961d6c8a4b735d14c85ca26f9685efca9342d72e));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x06c1507c05dfd0fa5d5977478e9e04c48b9b546bbe5619816f2a299bd2152010), uint256(0x0b587ae49bbf6d070002349a5719b8ad392505ffb79c0518164b7c14e6e815ba));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x1cf37cb5ac863937d33ad717c6f11e009770b5e24b024506f0f8c73fb70102e7), uint256(0x19a5c984d6fe11530b9328ff519bcf6f42058b55c3ad64e321ca05737247ebfd));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x0a9cf39048b8fc0e2011530dcdf1931677301ca3ba6b3b1b3f00c251f43123df), uint256(0x29f09739e83c03e02b797b2aa51d91eaf34a6cc430d88c029ad7138f42133a0e));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1be25c57918a99839fafea6fe9225296936d54dc8e82113d6f0d8fdb34080325), uint256(0x2642c527f56d53f60b29d31b30735f0cf29bec6d61cc31c562b5bd955440b0b6));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x0267f5bc3bf99a160012c29c90ca84bebbfaaa45f92417d23c7bf87791f2e003), uint256(0x241383a55c7e50fa9b73d0d3bb67dec7b6e3bdb6f8b5552f4cc30bb14bf10c20));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x1f76ac2fb5a02f2af6d53137784f3bea1c532d964adadee05aece8936d03b654), uint256(0x25074e97507a9669aed1357dc1b9952cf185d76689f70a5390ec8b29d3d6ddc0));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x2e31117bbe750832462a82d95c623a320bc2af5a27fbf5c7bdd570433615feea), uint256(0x1783f49d34c53ca957979eb02f7ff8949be8a3c227ede44c93f98b686dd29d5c));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x23da00b8124d6238bd2bf208d5b235326f412957f187ea436ea37080f48de4ef), uint256(0x0cbb84801461c39d40656b1ea2ecd0991ba09a2857e4f38c80e161882259f580));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x05c77850b506b3c71d767a8acaad1c087dc3c2dd33b4c1d2cf6bd894f6fa4cbc), uint256(0x0e92cbc8e960cdcda2714b6c175d258b036eb5a5209d497f54e351ea294d6614));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x042ff5677bd24bc3ca3ff9edeb4e15a6d2611642720eb5c414451784d3224dbe), uint256(0x0eaea26ca69d2ad9746667a2443ca245dd8fac4551d82a741d27e0a6859e3ded));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x22656001bd94142d2f2269df33b8e4ec9332cb4743f4cbc1992b50c9d3b08f00), uint256(0x2721dfa6b0094f7551df247d948ee6e380b4df9d0b199729c1d6cbfbbe241804));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x11bd2ae8b186a339cfa21ed8aecb469930f7f7990cb67102d04619c1a065c14c), uint256(0x21f5186e7f2291ca41a6fd16ed28a434b7d87d15584211be75a08e5ad6f866fe));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x2892500b368da1fd94074fff439cf8b42594e7b644b5fdb0f547558501afa963), uint256(0x0427a8b5acbd937cd03cff24ccce396bcbed26f4d0b9332329a9861d0253780f));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x16cd31143a09b5af7b7002b185c64db37f101d5427930122d883a30f005d02a0), uint256(0x13b8442c26b8c014caf72d00e6fd0c8c13bd0cef7bcea668af5bc9f521703205));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x0d988a5a19d8b4939f4ad2b502fdd39cf8e50686477b08291bfeb1e2bd6d1271), uint256(0x08b6bf1b7562798c5ec28cedff90bde9d55819555f705098e44bbc3de7098664));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x108235831bb359af05ea06d3742dc0b9b758476ac51460d7e6496a48f3a4235b), uint256(0x1db7ddd01015883efda443d6e9c7e298fa5f87374e0ede60d94b4a785b2cc611));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x29e19df4e18cd05c536aa9cfcaceb0d28bc75edad2508b46304584cff094d6d1), uint256(0x278261ba8ea6730187b09e0d3fd3c4680bcd7882e8ad1534cb3ae7d74ddc5c5f));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x0176dd6997422499e471eaa4466437736e08d21e0fb201781e1d38587b46d436), uint256(0x2b24b0c405a7ea3830795845df539f4b683a62a82543480a6f70b356a124bb2f));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x2c93f201fa633022816dd0f6f8091ab4e7371366ccb758690458bd96bacebdb5), uint256(0x29d5d30009b6ad8fe5199693e34a1a4d00a408b42be738a9b5fec74bbf956261));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x2ef2f7a40c6d180e0bc78cec5f613a24cb692eaf324723a88e47fd980d411df4), uint256(0x1d4bfb984078885b833b3f001ea2304f4b8aaaa5dd66625738a82272e33595c9));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x29ac36ec55cde1e982390b27f63933abaa85e0e4ea5f24c4d89bfc0e4503f4a7), uint256(0x1f6e3052d8d2822ff472b5e59bdfc87aefb9334812ec8308beaef2180d54b24d));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x1c66971d85533f65951d118956fbc110f3f4782eb381a18c5018d884459e8508), uint256(0x2de781653c80f9db8b7e38d46fd0a416fa951bae7dd62593b7031760724097c4));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x0f8ef02f1d13ba99e203613daf341bef276fe75ae8515c5c30dc61cd2bbc5e0b), uint256(0x0cbce431ac3fc0cbbd40451e4b0214a6dc65d0392e925918cba0c14094f31d8e));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x2cd857f216eb93a310de19e92221686deec6f9ed6db5724a3dbab89a3d65b55d), uint256(0x0b9ca001a44a6a0f422528d616dd38205f2dba9576c98aaf760a77023825acdb));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x282a78b4cd359a78e39c1a2df2dfa612a2a539f6c0b5bc55e36aad58f03de40c), uint256(0x073eae25aed31907945076857bacb70d10c86ffe74893b5ad0df97328c4c88e3));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x0676048868ca1e0d0456f6e3851dfcb9fc08cd62bb6814f41eee1bee67fabc93), uint256(0x26d04ae44d986a5fefc93bd5de0b8f579082a4bc1f067a1c47b1ac06fb93753d));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x08b46fbc51b3083561dbfde961a4c1c1686194b80d197c942c994ca9fc94cead), uint256(0x2ac4beb44d5c588b89cfe2e489ac01e24dbb694598acfba8d32eed59541f73c6));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x0f07c266bbf4fe489fa11236f5d6328d343d030d9dec8cba5cd7cbe7db12aabe), uint256(0x0bddda4f6111cafac461e5d2f40b7a771ac3933c11942b10e765f8d1cb78157b));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x2244ad26393910b18e606d9121b51b163108a692611aa4a7eb039e97639f7d90), uint256(0x07b492f3cac3c5f09ec000faac7a4ca4822546b6c2a1b2174d4392eb9f69300e));
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
