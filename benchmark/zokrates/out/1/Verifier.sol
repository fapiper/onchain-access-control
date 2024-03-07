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
        vk.alpha = Pairing.G1Point(uint256(0x1926934c6326968dc675a9a5ab6b576fbd533c14bf49e5d66768b463fa1fd8ba), uint256(0x2bf36555b1a6e97510d57c99879ec993b9ba960de383f7662bd8404aae035573));
        vk.beta = Pairing.G2Point([uint256(0x065c67c67274377d0cc9ddde2239f100f3eaeedae23fe6160a1fb7380db2579a), uint256(0x15536a88c1827c112ef0435c98f679ac717fd0f0ee2a5dbe50a7e8188b5b2a94)], [uint256(0x100afd70171ba6625abc310b36ac1684b73964597b3b8ecbbb6a66ff0438a379), uint256(0x25c04fd3a8da4500b3c7e812ea4516e1478feb3ff89a392e28e23fa80dad3acd)]);
        vk.gamma = Pairing.G2Point([uint256(0x23448f11f76ab99d9d2dd984728462ca19c9d65aa12d18ad7ad293254068fbb9), uint256(0x2e4a8df9a535ce82b327da3d2ce46cff9917c8d57c04b97bf40a66ba2e38ffae)], [uint256(0x2fa0c91644a2975b9dd99402c1aab79e1d4d991f61c6db3f41b82252c0f30178), uint256(0x166f732a38b596d1dad0f4aba68abecab6eb002bf92877b10b81ab5fe7fe0caf)]);
        vk.delta = Pairing.G2Point([uint256(0x0d88ffb13a247d10a791b78e4f84670895dafcd6f3918bfa308eeea92ddbdac6), uint256(0x2b03a3756da7ac5602fcb5587b661dead9e1f22b28af899ce3606f9531506104)], [uint256(0x2e4743c53baa524209abbc4a5891ac3a7f9986945005fc614c0d6d5cdb45e482), uint256(0x1c5477b5697da9b611851c511a1aa3f097c362140c6ba8cb8c790a1d5919c192)]);
        vk.gamma_abc = new Pairing.G1Point[](21);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x303f831cc226a1a80f465ed52f0801132ebf8c47d1df2b990e6c1cb6f9f22b4e), uint256(0x0b9b2bdca3f9d8977bf8cb0c79000ab71601656218aa8e6260f677e41001a5cc));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0211de856642c50cce48723db2db8f3e0a39ad8a544629df29dd1796813eb082), uint256(0x0637e3ded5601b8ea61a6dde19706e6705c76c6ba087801fd0d8d80341ce40b6));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2cde331a7878012433fb2bd9c8e5ebab9d1da6d9e3aeb7213c1209f70c5279dc), uint256(0x1f583ddee292ea818a221e974994a27578cd17f78b2da2b3822652fc553f1b02));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x225459666ff1b85e03d5a3c522757aaa3d0d99cb69924776a25a8d094a4211a5), uint256(0x14d951c3d1aaf2c6a381a845751187742689db757e3843145b0a29687080cfa7));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1dd2fe4bd5753d680f70c409a855da178fd5dd5cee0b98c9e7723c13d0a82567), uint256(0x1a134030d4786719ae8e90abadb33c612080051dcfec867970e38b68efe8c631));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x01139b453c42578604b226144d4b84172988190da554aecb3073be89617f6c18), uint256(0x08958aef3bcda29f8676ef089b1b560b374a4d1a9cbf89caa1ea89cc060347b0));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x21e28cc9eae0804d291795411b1c7460ded240ad596f8f2f41076ab164eba10f), uint256(0x3044c6791d55186de28c12a926e7c983dd2e4f29fca75dd58c14eb742c87da20));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x07581be3ce720e9d656acced387793508842dc2b12b19d9187f1cddc371ce39b), uint256(0x252443ac25bcf5ba0bb6870e2256f4ec9aeda8bd5a0e9e0629a681221b3654f3));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x095d055718e4c306938e237ff4c959bc365c0309dbf79604fae7193c90f8eee6), uint256(0x0e207652f08b9548f16cddb2e91e2e1b6967f313d5a27da20b9f1bfaf113ccb0));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0642fef01f84c6d6a492d8569f872bb23ba97b66b073480bbbf29ac842ffc83e), uint256(0x2d7aa35e18dc4152426d6ca5bbb3e99a4eb0361c4c806f7c38ecd75369334330));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0d18e4f751788cb7f07080945854dd836c8688474dbad4b8c23783bcaf869d4d), uint256(0x04d288bef4669e112622ab3c2632f66d56f4ad67095eeb6d232db69ddfdc7bc9));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x12c45a97a05244f7a11a5ff1e18d86f855193440c61d617d98b8ac8b4862a53d), uint256(0x10865b3a122163851559da90bd97eb8e2c44258738dc3797dca8dd5acfe16960));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x142fc263bc7693f52e723db488ee7d48b8d42f9e2a0d0117c65a25c5ccee0d5d), uint256(0x1daec1533e3110f47bee605457b830561d8edf50b93dd031aa6ac3b5aad2e12c));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2d6289bc5f9c1c76fb94f844cccd05ce8f6d419bd424684f41f45cb3beb0e5b9), uint256(0x06755396c462e304cffeb29623cfc7b70a3bababa6ea5ca51b701e77038eca33));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0c96c9c89acb066e57cb78591503b931107389d770ef36900f51343e26edc78b), uint256(0x2772be53a1fa4ba3525b52fb09edb3e7baebbea67885e92f8da043ee2e593edb));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x21046a1aef4e6a158d58a461705be7246641219f7826ef0bb2835cd478ec0072), uint256(0x057f8a236d10656b873b700ff45ea264111fc1674147b8b393cc8e379827a661));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x068369d939d92b9f89ad35db51a71db8622ecdd339fa5c76dcf1befbb26c2287), uint256(0x0617a763727a46b52d243d6edcc9e142fa246532d65976614707e4b7c5971b14));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1cd6652662c9ca49dec2a47d8917b58d83f6eff44f1b6328f7d1802e4757d77f), uint256(0x1c12afcacc08deb92792751e42446f693ccf028d938c210f619e88f6da0c240f));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x057e365af821ef332b5e02868641579a44cb355901dd1ec019ee61359f9bf483), uint256(0x0dc8aa6a517bd9bc64fa11f6b9d4c68c1057b42d265dc75c4d22937ca928f6f6));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2f85077650301c5610ac141cc00664c86dc8eb44a7a4faea9de79798fff248b1), uint256(0x0a0bd74cbc58863b6c75e3d5f71ca573a14d41164299471ad8985ee1a72775c2));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0a49b0078c18244cb420e3d88d7fa783f87b5b606ecd4e93bf73d9910bd1fca7), uint256(0x061b3306f126d734c2b1cff50f12f4420239c10e295e74333bc28ad2d9f36450));
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
            Proof memory proof, uint[20] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](20);
        
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
