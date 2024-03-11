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
        vk.alpha = Pairing.G1Point(uint256(0x300d6c6fab9b0c0939297f4cf906dbc346763a28bdbea56af6e9cdafb4bf9c8d), uint256(0x14c06a458902c49d17497ee966219c2da77378a6d4414ced58d8674a10ee135e));
        vk.beta = Pairing.G2Point([uint256(0x2cdc0a23dd8492a41fcdae190fc544a562d8940d0bde0533fbe62aeb84dbab8c), uint256(0x302bd97fb0502b7161be8db7bd24bc27904c72914ebf5f3001a28888bb0f38b7)], [uint256(0x25a321a1c3d4e6dce0de265af10788e9cd22d7f408c05c230470ae305ff5dc82), uint256(0x28f725b1ca44d8d158132ce0ab034067e0ec6d43e676fb17a6c89dee60e8a0a3)]);
        vk.gamma = Pairing.G2Point([uint256(0x22a7c4f59b05cf77207e2a88c720804a48124a55d44febb04ce9b43732317c04), uint256(0x236d7bc38cd9da62fa7c20cd19b1ca5b1432da95ce8d0b6a21b8ec96c52d2509)], [uint256(0x06c1abdf0dd3805f58ae7506bdd0c593e1d12c99ad26c2a7c01d7efc5094a664), uint256(0x2e0257732ae58dff72d61ad1071a0afddba59be9a4c4b2d33606c441f3c8ce43)]);
        vk.delta = Pairing.G2Point([uint256(0x126025139ebfa70c7a370d661bfdf80cacf28f43bc0397a40b15c964da9c8fdd), uint256(0x1d0f278b55ac1e8ab4c0f4dd3e0dde9e30da2db9aa0514969673bc9d2129103f)], [uint256(0x1743efd19af760b1c80322462e0519967c409ed3d12728f5ed52e178e5371bb0), uint256(0x2c456ae4a758d34f508f7bacb756d6de9c11f83b733f879308f95f71dc39371e)]);
        vk.gamma_abc = new Pairing.G1Point[](21);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1cad119eddc09666f9f13da65cbb6a44e8683dde77f990810878810131f9c755), uint256(0x001fac3ce63766526b1e09b38c7789fcfa1bb97565a2eacc1bde6279e8d42de4));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1ed3636e17da7fd1bebc7a536f58198114616359fd11d37f91f3d4c3dd4c876c), uint256(0x170d3d0a09ceb13c38077736792595068619438f1dc6b2e245b0bc1e8ad4298e));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x01119ccc2d98079268e8cf2ff06d7d6264b5368cf96874352ad396aa993287cf), uint256(0x01bae13fd6336ab88c1e4813682165abcc4638249066764aac5227de84220fa6));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1b0e341f87cac0e190fced63af59483ba1dc1ca333b1b1fee981f6e5642fcba6), uint256(0x20e867f2484ccb260389edd080048759682ecd863b3fc9fa2c20bbafb30a0893));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0326e744dd53ccaf0ad385422b6a27cfbf52ea8bc0bd134e9411c12fb173280a), uint256(0x1839d47acf607eaea60240b861fa4e120e581020b1c957a1068c374d2a3c465b));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1a766cebb7ad71cee8b1902a2ca79ebb266355a8a11915e2a01a4017f7e500df), uint256(0x010c348b3c9ca8897ba17f2cb634c015794b2d713177b1cc1353090572e00dd5));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2a6b0f3bef2f1ac4d34ba0f44465c2958b0f62610172d37826353aa398f09d77), uint256(0x0242eaf1d328927d26b9d0da805e8094bb0caaadfcfb6aac73f7729cecd6a5ad));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x219dfedad83f9d73d8bd635ba33d4d4abdf99464e915b079e9b6b1641cc453eb), uint256(0x23cf7fe893ccb33df88e2680677c968629513f934998ac7f9deb9a6711df16e9));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0fa154c9489806504454bd02a15fec59e59961e74a931756548cc98d92d8b1bf), uint256(0x21df33b268967c0f443fa66ce33ff67e613011e331649b352343976c2b03422b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x17600f7f87e901230d1833b41858ede7513c711c7ea5337632dd262c56dd9b88), uint256(0x0c8e8c550ea540778e2702483cdc960bca92ad3641469edb578a1e079d69866e));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x13acab16b892de7160cb1553b6b7e96af774aae076525fdb36002ce4fcc84d9b), uint256(0x0472872ae676f7d34bd468480b1cacb90b4028b0259639f7f04a9deef9790a8a));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x17d5b711835a45aa706ea5ce9fbdd8efb651c32dad084e0bef84220ff9a16a14), uint256(0x0ab77621a396a6317103039597d15d1d39132674b360769ba849d32d1b068174));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x045af32bdebec0bf391eb16de3f43c4b509d4a3d3b943e497d128f0d94ce5502), uint256(0x0c4612640529c361ace976a010064212e57e0524719ea17dfee8cd2784e102dd));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1bfe77b3ee2b21fd5255cf095ef88940a0d5c4f0697943c23dee5887f4d07969), uint256(0x1409561816e691889bd0c3dee3251a3b915f0387f6e3ed7aab0413e0e93c5b59));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2da120f63527675a81d5efd220d9ee461bb78264612f2165f3469e2b1e02e6dc), uint256(0x089215b7eb354f5bde7b7d2057d79d8373395230d4757b8250a5403a6b4c05db));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x27ca3432e69414934efd93e433c9da284c63f74d71bb5228eb56625ca54ed2c3), uint256(0x1bf74b2e6a6dfa6da97444cbe58b5a9a47be81465f16bc868aad65d2b1e26940));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x1a230fe057622087204dc5e81abdf7d6834a84ca5beaa6dcfb85844a5d0c499a), uint256(0x205f3670cd18c3b7f1642677cef4e6ae58a75c5f4e2c3e1d8c823b75a7c23120));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1376cfffbb198bc99f7073323c35441cde5488db1cd2ab1eec4e82372bb13b14), uint256(0x0274dda15b0d0485da01955c4cef0abe8ecafe7bbdf2a7e447df755b055ab6e5));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x26ecd9ca7df0a36b958a82c6a1ae950f51df1f25f95fa14031f08473ddcd7a18), uint256(0x22e1d058379277b3bebc5a21c87ffcac36665f1ad85109b1184968c04328dcad));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1d1bdde22759dd5c34645d835f55b396cb770e11913c3410f41e075f6b31bacc), uint256(0x2eb2f677bea473a109dd1e66cb16cae98147059356cea9db96996f288f228037));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x2a299767b57fe9a44ca3857c84cb3c405c4bc133a31dc8996435b5b4d85c5d31), uint256(0x0478bfe3f630746aff5b8e2358ae5cf49eb93f0c14dfacfbab10ddc46ae966b5));
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
