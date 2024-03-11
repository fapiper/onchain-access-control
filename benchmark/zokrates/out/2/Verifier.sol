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
        vk.alpha = Pairing.G1Point(uint256(0x17530c9217957a85713dc0ba70b15f26384882d06d31293528242ee1fca8fcd7), uint256(0x071e36a698c83d87b1923abe38c72c876f0cd9c903fff09b8d6cc1d4b98d5c63));
        vk.beta = Pairing.G2Point([uint256(0x02eb52550637703ce1a8bd31d9e54953d6e9d8618448636bd06665915ed53fea), uint256(0x130e20adcf24c8b0fed777f45cb7a407e3fd4a35c527b44e62d5b12e4be1bd98)], [uint256(0x139741ce893e71dfc6c39ce2caf87a545f6393841987f4328febdd034d1527a3), uint256(0x2a9656a1a4921fb7bdcf52260c2a7076e1db41c650a41210c15cf7a9a09f80ee)]);
        vk.gamma = Pairing.G2Point([uint256(0x1045c217fc8ed43987f75bb8e9ac84d7ff9700362b3b3025c803b24734e19232), uint256(0x2ef1c9f3b94279880ce38c6195c79cc424c9da7369f9ab5f0ce13a3f344cb730)], [uint256(0x2f1bbaa42c7cceb9fdb4c312b9427ab5e0a7a2623c1522cd2ff768f5365e811b), uint256(0x1c4bb102ac181c59524c7542353a31c0d53bda4908ce068caaa4361e9b7c6073)]);
        vk.delta = Pairing.G2Point([uint256(0x01cd8cfbc066e5c6c1c152bb3c5675d41575c710bface100476d7b81ab4849c4), uint256(0x0380f82f9b6dfe07f11e0db84a5bceb4db34b181824c88778afe03c17e222360)], [uint256(0x2bddccdc3920b96527788c2c09230b33b330b833308a7d11c074ea962a7eeaf8), uint256(0x017c42b9c615089981994cc42a6a8d583fc7dac8e00c4dc93f84b39f25e373f3)]);
        vk.gamma_abc = new Pairing.G1Point[](40);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x11e02a4e82596dbc685f82b138407120f0c3e2558c0c566a091242b2fd460629), uint256(0x15924b51077042edf125897263ba95389d5fac69c08f027e16af4ac8833ca7cc));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2e5cb6b3884b731678c0198fa7d364379e6b49a2a20469f9f349073608b58e64), uint256(0x219603421f4ac9adc194be3e430ac9b65a29f988dcfce82e362feb3e465a912d));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x20b93997cbab134d6a10ed438dbd9cf080127119fbdf4ba01c580a6b6cfaea35), uint256(0x120a232253cacad112eb2a8be1b954cf411c0622d61ea2ce8a29e506ad131a29));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2b20ac9518f1bc5f728b92e1a7ed68a16cae9fcd390d108ae991d0a31508b9e1), uint256(0x00edc3c9384a33fb2b4415167abcd12d001fd5ca164b0bf73de9d653b7f9999d));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x209c133bd82e895b32b15b1546f2fa3275bf0b33de4d3b5cfdc5569ebdbf05b3), uint256(0x0ff0f2380e7fb5c3b2e115d5f3b4872f95dce5acbe2ea675782a0d4b4e58d84a));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x2b5a923277c850a67078a2eade4a05efcd07ee43a8a9d4260f45a7f5d7da05f1), uint256(0x1c6371dd48b03e1f5e94efb6350888deb99a109411c6507610af1e00da7da3e0));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x018489bcc21f4b4253eb6068c1fae18f47fefad26c54673eddda681fc49f8db2), uint256(0x02143858d67e8d74e7ed3a90db556465c667b4c26d0ef04bc53b118e57508fa7));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x27eb30f83b192ee7b51487a1abaebcec811ddaab7e502e6f91db10050f08acf7), uint256(0x24c9a26787c0e9197e64fc0ea5f83c1de941b8daba218dc2407587b75cc02607));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2b64369a56597ebd4432cc6bccb362f498d366e8770449826d4c43d8325530ff), uint256(0x13f025df16865b0483001acd26e00c97419c650567d27a12977c97fcf584eb54));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0a6184f5788c2a338543f06dcc8c89c47f8b82d33a2f80d61212dbb49331cc82), uint256(0x274498a38e56fb2ed130789dc852b75d11de65c35ad7d310560796a3f988406d));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x09a4d9847f2ac962f22fb59a4433221c3a8f492a1959b6755e99e16cacd1ebdc), uint256(0x2f885518c20f9090863281eabb17a6e419228ef4c8d7c5f275b468122f0e7a1d));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1dec8157d721ad93ce6e833c4bcf860094efda23f3f39d7fa163716a0cbff81d), uint256(0x1512478a69aed0891932da1fb37cc43df84ebb66e137dc333ac90c8d3c1c3b0d));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2ec212ae9d688df80e46c4202c26458ef86b9deceb3b85a964bf6f7e96fd76c1), uint256(0x1a189074593f310e3bc4565dfc3b8eb56332fa3767607557e67c7bb8554342e5));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x03dd4d818f188b06e9fd4182fbad06c46cd1efb2a96e122453fa6fa7eda7be6f), uint256(0x28a526808813e296eaacb4f637c8514aabba7ce301d84b802fb99df3da29aa7a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2d6b6eeb92014fb028f6ac70ed2ca52ccf1f24f44f3db9c486fc53f14a5ed240), uint256(0x10fc8179fdfd5742d478b13471d3c1e2494b2db8c027db207abf9f896e1c9894));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1090d3ce8df73d92e7ec5df13977f0a18fc13819f36d137f6e02983e20f677eb), uint256(0x18a04f16f35145100e65d9e5f625754dcb4088cdb7b8ee7f43f54d1451857e1a));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x24e9842c22836c357b69fb5ea27bb019cf0e60bd8d0092aba98cbce2c9a5ac66), uint256(0x1690920852700c610563fefec6bef7097ac9c6afa1db382a1a642de41299519b));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x035fd0a539f15be53ec1a4270e237ea0c31f1d6c7242a3074703103cfa1dcf48), uint256(0x27c690e8e563d1d78c2394215a7503cb1fc44d4046e494c08aa2a7f20da469c5));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x28d391d616f34d342bf0ea787ab1d9d4ba425423629081381ceacf7043b21310), uint256(0x1d744fd1a84325cd4889d79a5a1617aa8e6e9687abb155940b4e6417d2a62227));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1d3ba62d5b44343be97bf79541f4dae531de68bffd6a48b764823976ec37c871), uint256(0x042c8427f99b9bfa9b8abfde15fb1e620c94eec00958264be5fdb2cbb08b9289));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x25b2891940e2bc00b9c921433ed0c5aaabfd3a5e765443ae33e55a88dc17f70d), uint256(0x088189df84ad9a67bc4cf51ab08bf13c474bfe79df407a0aca2a5bc02522760e));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2a6053d29ff0823955856a8123373739402c663faea492ec4c494c91c96f77f1), uint256(0x0b0f92d651a3acab7d81661588d11be2cc4ec2d5a11b19a76458f590301a94d2));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0cae989c774668d8a0ed498f3710774868b5eb872c22fa4e90d256a502a484a9), uint256(0x07546040bf13ff178cc529a7cfb2cad8c2c12bfc7197429420fb4f214aebb78e));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2b61efd25e9c04a4aed6cccc1d8d8e71d11f9682207077a688813f930e5d9d42), uint256(0x0fe2fd8b011239a6a765fe2f045e50d6caf1b43af151cd76920b9e7a72519576));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x19b97070b17c863d0a03dbd6c31848d37343e5dc4c930501ca28021dab3093b7), uint256(0x15c4119adbfc056077dbe1ae943b1e78c53ecf75c039d80bd7dd6dd10a0d7c08));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x08aa13ba1ecb1e5ef05863edcd1a23c07848cdd8212149e5411fa4ad4a33fa12), uint256(0x0d766406434acf40a4b78bbe6d07a135437fae49e26c4c396bebf0dea791b556));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x1c5232060e54d1a5c959c8a765a61e69d4411cf37142d1d6d0a1a8b3e2d0b65c), uint256(0x19c0047d20460248e047ea8479245302440a8734ab2826a716d2ffe471f46283));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x0b31ba7e46b88cc7ee1ee64b877b4c7c73f696a60d2cdbf00f46663b9978f9b4), uint256(0x1b15cc2af6f42e04f8eec61142b71cd862a6ba64ed070ddadf1a284e1873e80e));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x1968aa04f631a2ef782e60e761678066d736200830895a6c3c1d81e0d9ac47c5), uint256(0x0e929cd79472cbf3978883cbb9ccbf99cbc3c380e0eca60fc26ddd8a034f5ab3));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2e34df8ddfac783d76a5f381fce8ce5e7173654b6a71babc85c727bfa63425f9), uint256(0x2ba18fbfff34291a91c0d4faaeaf856e6ed4b808b1858533a0c3a84301ee9a87));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x022f1a40062765bcc7a8cb61d6c1238e289732467aa4fce82c7d63af6f9711ec), uint256(0x1b414027ee2837da7ac0e9f290a9d873fdeb20941749f6fcadbfa058f5105821));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x15d099674e104abd238468b72cc52ffa5b538587afd42807a4ebbd763bd76bf1), uint256(0x29929b3b002ab1dcd3c1834edc9eddedc7ca73a21152fd27ca36db1fcb64a133));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2930206ade4872204d94b63e3cea2993dc6d994a51b3d58384fdc13b57e6d667), uint256(0x04ea8b20ca256456e9ee99232d565a1d9ac1e808064c6ef35e0a8e13b3829378));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x0d77d6e7b5bf5adfa26dfe4f5e0c9fef319e1adeb1838514da0d755279df084b), uint256(0x0a119dfc80f07c7b8a67829549f3ac26f8866dc33896d4c680b112a11cf10148));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x22de4e456a8c15e328e48adb7e2355b6e7e2fde5a62071e36f965acbabb26695), uint256(0x0e382491337c7d81b4bfcddba92e21db1bf8cf24d3d658c8468a695bb4b6a007));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x123582afd04da36b1965fbbc42bbd018dcdfe0aca160796168af06693d5ac97c), uint256(0x130cd15fd0bae1705c067e813fffa35d32993f79a1fb7a670a2ba0537a8a10e2));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x05fe21786748e60c207b176b31da6cb2a764dc88b24ce80953884f07f6892583), uint256(0x1fa3fd862671e227d687db8c9cb98df2820ea31a8685a96f21efccce3601e0f4));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0936ab1c8a0f4be50f827e7b1e66b798dec3426739b76633f06bdd218a8e7d86), uint256(0x2ac4ef1246cbbdc744a1416835359ac6f8541fb5ff57ebb66328f8b6e99c62f9));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0685db3b81b685a79f10ce909dfcdf9e4507c8c087bde489fd9f8c7ef9067437), uint256(0x2a116297f66cafdf475aa8ae72ff297d750278d3f441676b77e8f66501aa067b));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0bd0ea3136a9ea9a102d87e7c5e371f86c96aad76acdd2de1455d1f783a06f95), uint256(0x2f09e475c742a62c4b25bb86694adbe8399dbd691d83ba691d79e3f63fb2746f));
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
            Proof memory proof, uint[39] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](39);
        
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
