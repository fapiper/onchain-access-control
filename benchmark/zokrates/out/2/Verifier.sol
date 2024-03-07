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
        vk.alpha = Pairing.G1Point(uint256(0x0bbd276366a2d6aa8c96d9b803ea90699c47d2333ddc7637495e2883d61bef12), uint256(0x084fd7ea50d21e3fdea059da5b16bec4dbb96c618706dc81e9076b6b869ae653));
        vk.beta = Pairing.G2Point([uint256(0x2ac0653b624a91971c63daf153bef357896323dfd5db5d71799e1d3b86784c89), uint256(0x1576276ceed02cbec9420fb5893a1f84f644409f0a843946a43205e869031b77)], [uint256(0x2b88016bbf5125996838aa37b5c3419d91de6e99f4e8365b1ff0a05323bf38b5), uint256(0x0a630b4fe28fc2e3a9c84430e23b969c1b2e5b81bdab75ebed255b865217c2c4)]);
        vk.gamma = Pairing.G2Point([uint256(0x22fce072ac0920141276694c905320cd4de6f95d75be5610554e1275d2b23613), uint256(0x09d1d42e19f9d7315618465293ec931d96f4d3056380bde9b865b2f8c22c308d)], [uint256(0x0c22c7caec5b3a993125637b4ad96bcab593294aec92533b075c6e07985d51a3), uint256(0x2fe4efcd00ff2dfbd13455eef9188a3d7e3249a84b463ec310828d0ca166e867)]);
        vk.delta = Pairing.G2Point([uint256(0x221875fe84a2344b70bfc7252c917ae7559d2b687ad6db7c2c403697c2905ec6), uint256(0x2f96f0dbfb3601fa3c46cd1d8a0056bcb0ba236c05c73303bcfef1b1863d3d61)], [uint256(0x0c933df8871b36c1573dbb9760f210cb0620296a0d3826183331ce915995c6b2), uint256(0x1d07cba625cb29fa6ca6fb518c3061a6e697990c8319eba70e808d87a90f2336)]);
        vk.gamma_abc = new Pairing.G1Point[](40);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x05276cf137090f69ae0950d30d73bf92ad110fa6a581e0e1937ea1c28918b8d1), uint256(0x2cf90cbd659b8fe59b922d3387024c8293a9f2c9ab190f99be69799d9999d165));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x07cd8b272f2f7f95a5274a89915ce2be7895ec2ac41d0687159d49104ef55aff), uint256(0x17944423dc6edd392c2828cabc9d2dbf5436742f0798d0c40b15bfcd2383912a));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x06b53a621e60294cb8c0b57fc4332980a5e5abd3401a17f636378f438b4f1cad), uint256(0x09ae47d4e0913c78dd0af1667f9985ff923d86ab487bb7bb2873ac5a6af4a466));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0d2028499b03d315a1056fe343f07eb781ecc011eebe7c12ae381e1f0a63f83b), uint256(0x10351d9b289269d5303f64084df17b7c676268de526854cf469f8a1331cefcb2));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2e144d403bf1f290b968d4cdb620fabc3ac0b19581119e9ae474d8d071592ecc), uint256(0x2044bdd9386a86860f1628843ec423f26d045ba387418f63993b45834bd6f104));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1ddffce8541880a3d04581fbc042dec7bf3e5e315086b6a3c00e503ad81a5ca4), uint256(0x152546d8fa100b3ecfd4ebad08b3f2c792e783aef120fec5416ad9a255c20c31));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x05ee14d36d4b61af8237339528709a2e0c934c3530026d5ad340fffbe80e3bd0), uint256(0x2d72c5acc741418adcd34dbf83872fae29be5f6c26e6d5d3214f0ba36db0228c));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x17dfd1aa3e8c78b18ec713a296db4f35a7fe5a0e37a45942f4c1cb983003e8ab), uint256(0x244adf3afebfebb7bad827cf9b047140e61a67720af39420fbc76df28a5d27db));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x088182f6b3af5de45f81c9bb228002fae978f1981b85b1a3bba283930c352e76), uint256(0x2e37a46c575cf4b017d147e5e002e146fe57ce6af365c9b4917a1cb7fbd164b9));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x10ea388024fa4293359eb7dc3f49557081dddca41718d8df93d55c5408624fa9), uint256(0x104fab9f43316d7268c1c0ee4c91bff3ac2a758d75bd7ba05ac85f4ad963b684));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1333188de4dbd1a1dbd7fbf9748dc05edd6abeb449487b459a758625dd487bed), uint256(0x2b32fcbe9ee8dec817794f19994bc78366180eed96ec6832a90e7e4221f90259));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x29824e9beb4a29c3642c6b87aecfcf6d97a46a941f47beb316a538404478d1ef), uint256(0x1f906618afff16a1ecfe009457152d7728ed7ce51d0c90e6ca0a275928791148));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x07afd1a273fade14a6908d97abd3f8b11949b8a7678fd0521d94d6918d5c857c), uint256(0x056000dc5df56fe670ca60ba6b42ab65cb9e620f67cb35ac854214574bf28576));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x151eb01e53fb48ce17ab0c0d84bcc20bc4e14aa433b05fae8df63302c61a487f), uint256(0x0e2a0dbba18258f65828736b888db39d76249556042d4c6ff8357773548f7f3a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x14b94a4ea858c5543e3b1832e1bf255dae648ef65e82c035af7489ea1ddd6fcd), uint256(0x17d8827ac16a439cb4c31fc1de9fe94bf4cc135572f797cda9ba70c5ce1bf6f6));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x0473b19de647a517eea5c1f7131f480c20355fe3281e3ed751acd1d43e806ef7), uint256(0x2c7ddc2630171d9e691b86f9a6ea28a6ea64539888d40a9aa1e974a563844553));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0cfeb46790935492dc7b11f2589ab8eec1eccc715d4af0f19a21365e90f8e3f2), uint256(0x0a7b6cd6c077709ab20faf8f283b2d8faae9385379bc9baf5d4f8aabfc3e7b0d));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1097fdc94f4459a380e57cb212c48b79ef8756697a24d3da755e4b527f28ffc0), uint256(0x052ca849b62c02b2fe3b3a2a7085625be2cbfb94df16f00d1c263969017c59ac));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x16647fffe5a6c8b6108b64b738914a695252f87552dfda4be11ee5b853977be4), uint256(0x28a99690b884fdc8eec811c14bc310270f84cb68bca6b5d0cfd96b6d22927a1a));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2cf19fbb4233131fad0de2e8adf9b3533cab5925387469563bcbd0dd87b23fe4), uint256(0x2676d67b38a28ce6a35a26467e063a57571fa4bc74aeae1e60928d01eae7e546));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x061e6e85901ed9b4efbeaa62e61cf06b989819e7b9d9cb13e27055fce6f935af), uint256(0x2c414a60ac544c1679f72ce9320dd778c7485fff59d3309b9158fc89f326610c));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0da5af3a418b05ae0de4055d7c6ae51875302f179aa8505564a667d9e375cd7f), uint256(0x1c9269b5948979e9d6a121f750ecd390128019f771ecf745e0e43e6c1c435fbb));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1327abf95b4b2b78db6712a051ecdef8d80a40af282d6470e94ec0cc1484281a), uint256(0x2fba88d6e3636f9481a55358a3be5ed465689726e4ef997ca0ce6602960085c9));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x218805cbf7a87d536ae79a5489a5ccb5925cbef0a4c7537cefd9930c8ab48827), uint256(0x0776f2f2bacf40be315f05fc577d967fee2c7cffabaae46d0a51072fff58706b));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1d56142b5c2981f710a995bc9950d4bad40764f106102c205fc20243c03fff2e), uint256(0x05af5e9ac543326d1414bce66d53212268b9160d4811fab010de7ce936ceffab));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1e37e1e2126ac31aaa37c62fe3bf5e591485c6960338e754be6d92644ec4f55c), uint256(0x2316ac494befc95a31a4b037a472975f26603020af38ca19d5cb698f64fc5492));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0f39356082bac7dcb0b6a695aca4e8591f5fcb92bbf0050882626929ed73baa5), uint256(0x18d41b651990b8269e69ce9582408a89a5648250b1c123936c1a35ae7f0d083b));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1de7cc7e3c918b64d47567bdf41483c2c47193e6ced4f5af70b709b1f5d5becd), uint256(0x2ec1bd0d23c7f4dab1d19fe3d838a7b86e22a5b78d834511e5764e06670c42c7));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x036b3da63821befd9e2ebf85b7dacfa497526cbb8a148172395edeeafdcfa281), uint256(0x00193d2e621ae83d7521c8420874d3f131968fd98f5aeeb6fff4a1291b1138ac));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2ee9ad338952b410bbfd4569699def605040e390703ca9076d6ffb3faa151abd), uint256(0x159040c2945c0f718bb173ae68ed0a8fb2dae6a5d75f1c6345b14dc82703e3ad));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x00e77924e5c260d65e0dfe862cfd9d22d701f8ede3a773ea13b762521be2b5f9), uint256(0x01a71536e3807b18f3c3e83a761f5c8fbe4a6ef05f525228bc2588b65be66e63));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2b90ca63652e94e5c8f9488c8cc6f3bcfa547d191d1422805fdb5041d802672d), uint256(0x0ddb9247bdb971e35ec0bb67e291912e5c914564c7837190acc6d36622a55fd0));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x218e09c1fd3e202efb35391c873ab77b362b1ecaf33853e7699a175d36b14e63), uint256(0x09b5c0e4d73983806adca42bc4103b056c226f1472014d96bbb6ea8bd10b532d));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x2740f5f6225b016da229937826bd790afe3c5b9010c1296a47b1f94c406cd3fc), uint256(0x1ffa81b932c2cb189b85ea1a318617f6e697fe5de7d93ffa04dd6dcd58d434e9));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0777874a024913093da10657b8166c58d78918e508347d7d451891f5b08100ac), uint256(0x241112ad9fabf30ddb089fd0020752e84b2ba06df0e6cec43d6f3cc4d8b9c0b2));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x2e60851b62e4326853fd4922598e5fafa6d7136cab1b047b88b246cccde662cb), uint256(0x2115f8976a4430e4b35d8fa28b655b7f2b18df8648c7dfc4a7c5838126e3a97e));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x2383ea4625f81e507ac550cc3a740c2f2323db043c2c4600a596b8ff7a697e6f), uint256(0x2ab44c56808814704038c60004c151967f293ead4618c68a56fb75c9b1c4fd81));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x1c193024fb2ed15985414197c5c91bc31bc9452d86d05cfc9089a857de74aa57), uint256(0x20a5de2a93511ad8357631089ca13e56e7828d6d8f4f26ba254a61d14c7c4204));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x2d3b31ff143b7b5525c753f30ffb6ee589ed025e29a791d52c911f2013b20f9c), uint256(0x203755a7a20c0ac5e082b04d1a518a87ad448c83da30783e0d2b72326dde1fca));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x2736121bc841df46f66dc413670d1207e1430b44627755adba76230b2cb24974), uint256(0x1a2dd46e9808f3cd94b2471f01b1afd79edf10f2a89d448bdb8a17bf7d085c1a));
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
