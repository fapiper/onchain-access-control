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
        vk.alpha = Pairing.G1Point(uint256(0x2237b3ab04faf649409bd08afc21ed3a124436c3be9a341b6216e405d01b6656), uint256(0x248b97cf9f17be3e3688d0f48581b15e92a85e8d32c76cecd4a8a1a58028b5d2));
        vk.beta = Pairing.G2Point([uint256(0x1094feb132f91bfa6815c77eba2479c878aa9a1359306996906cc471e51131f3), uint256(0x03aa4c4c511abeb3707b6dcd3df51166962cb2d312ea85086ef80a8637182fc1)], [uint256(0x0c2dec5cca8cd1c573343812648215011e7f64ba94fd3958ee4dc304d98b8d93), uint256(0x2a416d8b53b81c7552338b08966ade8fb6d7de7f2457a068bf6612083d9b047b)]);
        vk.gamma = Pairing.G2Point([uint256(0x203f71971c61848695eab6f702139839270513878f31596455840c0fe801e3f4), uint256(0x2c16c28146eaedf7c9033a62c73676d5c140a80b59ae50326609af5ad0a16576)], [uint256(0x2164aafd17580b16a20e163037550189e0d141ff775985c37dd7499ebd43acdc), uint256(0x1d68ed78a4ca22a8b7531f7cc898d9fe96fb9a81cbcbbe39427b285bd1542072)]);
        vk.delta = Pairing.G2Point([uint256(0x28392929ac024c9f8c6a4c332404a469df3c356b18ac3ba04d5970b864bb5699), uint256(0x102502eda7099a1f57ed1eb1685ce9e86b1946d112223f9d1e3b2e21de054dbf)], [uint256(0x2464d29c416e41becc72aa28bca94f865fdc34533990958b228cc89dba807405), uint256(0x209dd3dccf355e555018d60b1a6e9b35fceea9cfd81f2d34638c9534d6bfdbc9)]);
        vk.gamma_abc = new Pairing.G1Point[](59);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x18748664172d0e0a50b3acce94f4525a2549fb3fbf5f626414db6b48f26cd7cf), uint256(0x05659b3a39392dc8f85036d42abc9f0a5939aca6dacfab7f17880ab432d8f822));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0f509577c82a314733f15a4646f42a3f29e7d44dfab03827334c74844c63d16f), uint256(0x1d5bb407f139e1f9c65214ced81bf286c142c6adf983e10a47165a6d4bc0a931));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0fd1530020de98b31c1cc7ea46cbf7db20b1c3e83fc2e83c8f8f1ef530e43ea3), uint256(0x2f86b86ab4b941d71b75ca147e554dfeabb5f48225ce4c05a1a7d43806040c7f));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x070c82e196f2fa8d967870855c0d01b67fb3bca86681f2d305f42e267c86da8b), uint256(0x24d036c7a1960f9b0f71c65e4967e87d6f4793f5e0446b70b87c45c4ecab28ac));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x096757cf3de5b29617a1fd5cb15eebbcbfcd3e8626275f1ae41939194962690c), uint256(0x1dcf30b310cf3266e0b6126b0c54992a08dbda8d31dc227f490aefe611135f99));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x20cda728ba71ddf015ebfb2bd52edee54669342daecd53128f8fffc8f8bececf), uint256(0x0b7f0182c07a138ea8c90b2ec9b0579b017a504b9d71d7286c67239cc9d2c95e));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x16c4f1994b7fd9cdd7a60d679751a4c33809a82746fd4e643968c5c94ebdc667), uint256(0x0c1911472b133151e8702966a42abc7859c663e94331620a6aabe03ac3c80833));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2d74a7acc36c2baf2e840817d678d088602138260d53e3ea716426d7416b2d64), uint256(0x2c2cc64b4d653be06f9f6c84367753ef96769f7c1ca77e234e7e39366fa8ddfd));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x25f2bd34af5853fd1a264f09a2c1c54066ed4fab93eac7f534ce03f1d92a0ee1), uint256(0x245a6332687f739bb94e7d22dd36736d1e7a03c43615a147e339a5fb03b265f2));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0dc9d816c29202f5352756ff30e64c2bba7d828e066da3e64aaaa6b30fa657c9), uint256(0x07d7a606da5e0f126565f3745c5c99d4989173ed8227672c1e81bd65d167b9c9));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x24ecc447103957474f25dc86354e3f5e620bcb0e78537297248da201e03a82f6), uint256(0x217582eada4b09602a579e796e8d3299a8050de899063178c5837989d5c85bff));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x13f243b8c92f7e79b22a248e1c91eba89df6ddcc2ce16b625c3ebfb0cb563663), uint256(0x081b0d445e8664d91db903744bc5f12ee986f9a52eb1dd2cb8a2f9d2854cd5e3));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2a8de0e8414d172da7f14d5e4b30c47baae58c8598bebccd226ba1f7c60282fa), uint256(0x12a8bc24d77a625fec5185b1345c9d2dfbb3c7f1adfb581b71a6e177ba8459b2));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x003a2f7c2889f9426e9dde6bfc31f9764252d0b8818fdfcfd36cc244a277d2dd), uint256(0x18ab1abdf67df76d0a64960883b3f44f5497910c16774dc4ff81bdca6916d44a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2d6222b81fd729437604ae9e9c9168054ef8e8cd3179d4b2854836be25b567d2), uint256(0x2901fc3d3c425ad3641ae2ff8120a5f1430fc9b13d71fa1f86b0a5bc7fb79581));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x0cb7ab06e5242724c898df66a0eeb613b549ff6ec2a3d9a6a6f7f65e39119b8f), uint256(0x2e7d1653e43c86f82d8a71b95be86827035101f1d417c45db25117c79d8218cd));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2e03a8634b4f695b3f16e2d30e520d3809ef66fb27a0bc2b87f84738dd4d90b0), uint256(0x20ac149e73715531d47c36191232720f3a9de694db47ab1eabe48f14c104f6fc));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x04647264244d349353266fbbacfa51fd2d803d66dc23bbe875487265f27e9ce2), uint256(0x09c3b1693fb49b30ab9058e3cefda9564e875caaf5f75db917f2947c4196c7b7));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2d5740ba1ee7f4af85f16d6d03dacd8091939a83544c655588722044537e440c), uint256(0x1da92e2ab92c9ab5b16dacca86fd00edb1755ce625f7218057411ff58264b83a));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0910d273cd9bd507222a42114c6fb50910e220202efeef2f478b6139b540a3d5), uint256(0x1614e5d6f54c07d95797a9cb891f9e3c8bf858970aee3c5723f92d3fd8b94bef));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x204b215c08e7042dd418c0434be3f893c765eac9162fb903b9c596872c1bbbc0), uint256(0x190b9054a730eeab30b28a89fccb6707e1af000c9b90c02b65140ac8097949a8));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x06ccc4f9652cc7d043341a124b224977f1c85d54e8fd31613c6dfb4a4aa4c9ec), uint256(0x0fcb40b9ad26ee603d4f5deff1c36d54fa91cd851881cea222b3d6b73fa7fe8a));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x145a43540af5bd99bc9b9934b512c1af7b9081e9e7ebf99946b4b6e07f3fed00), uint256(0x08f65530580180413b370ded6f39cb1f97a7b64c777bfdfaa2dd7eb763a04a7f));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x02652e8338c4b2c740a9df7b95500ca7e0268ef014b14185397a444763b4bf7d), uint256(0x0087c0498c0952c241b780f4651220644877697d5777decee477655c0628f0b4));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x25c935d64d6c279183a7bd397530d23e53f3cb83bcd5d718ff58b180af1d04d6), uint256(0x0914a690d8e8ef0d4447d626aa2f0410ec317efec46c8fc6049f8c428a853634));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1a9031d1b693f908da7451314bfec46c1d512263446021a74d909703dabbd837), uint256(0x1276c1018049b292b539c76e8a4c56329546bcb2a7021bcb420cba9f5197465f));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x199042076130410cd72ea579a37da743b478bc070155a6356c5bafac608ecb6b), uint256(0x10c152199f29dd75aa03d33d00a6d883f8ecbec2cab40c3dfbfe8807aa4aed6d));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1485812dd6b4177f68834d1b44d3aaa185ea83592ace4dd319d9ecc199d3edb6), uint256(0x2887cd0800bd28b8c4b338df0223331bd5eaa56fc625be547623dd4f5b368f1e));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x1a76b6ae6cc8c3da4deb89edcd4ea63f45bda26ae5699934b8b430f8ff2474d3), uint256(0x25a6f548789761ce474dcbcbc50a1d9caf9ecb5108ce639b68906953c0d95bd5));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x13df4830b66560c46b63d52142bfb939db331211b16972e985d648afca9cdaf2), uint256(0x2f52aaf7ec07bf2211af0168ad0854ef978485e6dc44b8c70ffb615a2f57d195));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2052c19060763e94d3a73e9369ccf48645acde62cc2469c1e24c0415d21c1077), uint256(0x2beea9194bef7852136c3d289b112eb9481d83b69aa2339d8cf2501da89eaa9c));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x1cf8637a4809b167ce2634725a396e2b7c69add234edb093f28f14ded7b4a7d0), uint256(0x238677a999d0ea32ddaa4762fb3aed3ec22072a4a1c5f04084ded1803529ee13));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x13447c18140697d72b583c4bbfdbbe1ade664b7773ea04f662d5cd3e415aa0bd), uint256(0x0a21c1c1a2955318ea76a209aed52c2d463b0412051813798f5a736697dcbeb8));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1a6eb37c08ef6e1b572c883655923ff7a58dbcd5781e549c3c756a50f1e8b12d), uint256(0x1df87a1276e5b6ef0b939da66701824d1dc86261386e738624a9fc70e5642640));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x28c4eefee3d1f052d49f1daee445ec3bd30bbcc2a6da027729385347b336b38d), uint256(0x0c9951eab7a006e9ccb217dee0da900164af3ae98619bb76041ae3760fcd674a));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x2d753b83af32f4f286789c64426690675c2639931ff099889487f2108604ff08), uint256(0x2aa7bbe3c6e49940d0d776061518446e25b6b1f068674de09d1c199a1fb6d9ea));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1dadfa1b391229828900dc356c10977f9fda595e1d753681b739fd497eb48ee2), uint256(0x18d79c736d3bef2594fc558c20cfac9549f21c88d3944bd1960b6dfb1aef3533));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x2434694a04eeb7e8aae58f5da56f1f2258bfdf2a31f9d9cc86d6aa3aaf110c4e), uint256(0x0c69d57b1fa3e7ab85ce363159c7b8728b7602382f4b8148fd29e31326969156));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x02ae293ecbcdbcb1848dc2961ea77ccdd2de8c2a3a4cc032bb7ecb7d16e1b7f4), uint256(0x0d3f6a17f002d4f26725f0bbf83dbdc99e8a91d9829e5ad17f516beba5e24768));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0e77ecd0a7e34705c41e7dc873d2c32d0af880e1f6187d45e59923473fcc6323), uint256(0x0d8ea5707fd264019c1ac8ab982f9db38678e47009d565954a080f4b91c99b48));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x1b55c90a95689f2eda25103607d2a17ffda371eaa39fabc4a9e350da0a0bf22c), uint256(0x1dbe9c2120cfa01fa6997f5107ef474246c15d958d3c5471205373dad731958c));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x278ffc2270ef4dc791319c075e62c3fbfb5e8103381ed775de246e8418793524), uint256(0x042b41002cfc9639c90a578b530772eaa1dbee876cd895d6262a52e6b3ca3cb7));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x04ca2c1cd675e48e5011369e5740464393bc95722d9500a023e64e585dfe36aa), uint256(0x171a6f25463384eac7644b1e1ecf30ef8519bde32866c964aa3d5f71c4e50321));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x12d36c7e843d0f8a03ebcc03dd06cb9e91b1199ed45faa76ab98d6de24154d2f), uint256(0x2e49ba9e7b5c63b0ec5d6a9309586a604d03bf11adb3aae9818aa93f4cc569db));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x139cdb26759535fad85e747038c0da1b53bb64a6bcab57c06271e3a439aaeb63), uint256(0x02b6e477b2b02a841b13100f1aabb94d2edbf1779ae98cfc115d0609a0a3e704));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x01a748ed83e08460bae52371f261de87511e7fde975d73564e809ece00d2e971), uint256(0x2d3616f1b4f935e7df53b5a45f92542359e63560f7430503581da2b39052dd1d));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0646a8c871f812fd91afecc2ff9f5ae2974d210b16b587d545ae2a434ca6437b), uint256(0x03f819bb8f303c9cddf27585ba8894edca8c14197f083f0a459aadb406c37769));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x1a424aaab262e669c6cffb29d8114d4a4ef7a6b5944048054ac9a7301f82c1a7), uint256(0x0ab2298b90af746612d4b971c85418483175e75ff3888598899b884155828c9d));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x20faba4880beb4044673e45047f742369c6a8c967e3cd78ff414fb49d5dc7488), uint256(0x2f10425bbca3470b97fcfe3555631cb49632c8c261ee54436799a09b2b5303da));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x1c57544682ad41de561db3d59fb1de90ab058e145922805201ad6c5b4b4be52e), uint256(0x1aabc024c915e5a2a4bbc5618b6f256de0199ea929e33c394a3051237f019587));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x0eb5c6977b499ce59d7f4227ceb6d96c39cb96272bd65546dc716e6ae5518375), uint256(0x2f1172644621fb54f6b6388bd799382481aa4b5f8dc954daa7b752ec5dc1ac2b));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2d35dfe85a115da9aa567c11e910838678c52f45ef45b575167e8e73779b3a23), uint256(0x14cd7d492d1606ff3d4bf2c29273a9a57a128dc513b0da980102b385ab0888e3));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x096d5e6ae89fc7f6a9aa4714958139ea430f47bea00721713710e139d4557a92), uint256(0x09cde5a159145163adf71c15f6649f0208ca9c980e0d606a35c88cd58272fd2e));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x1c39e5c5982faa9d7f542b70502327d2d4db63ef27d3a9463f9324fb4a066a10), uint256(0x22899f6accbf7da917886b12fee081556d0402153bad26f786eb9651e53b2354));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x071297f48125e12c55e07a2fbad3d021093e913bb77e259704ec9cabf1bf61b0), uint256(0x06ba7ec49ada61b19bc97021c998f73da1a693fd021ae2a85ba1afdd31b4a2d6));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x2440b791883a9919b414f2bd2da46ce5c4d301ec244e8cf09ac70a13510bb367), uint256(0x05d7010cd0b94e01dc0f2ddb34d8113b72a2f04af74067fe61f770c9c09f2937));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x11bec807b14370ab934958f512d89bc3fdb0889818ab6f3ea1a5e916c635ecba), uint256(0x18a5730401476765835371f8150283278c3fbd22dc4d4c36bf00563787fb63e0));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x116ebb25faf9eb5585c3aba0df2aa65f59c43f0b99aaa6c2a4afb24072a10cb6), uint256(0x231865b59373575761a61bc9eae897101af8714c252cb40b02be3a3225e92e85));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x0a38220d6929ef1b0331ed64c1a0c1fd4c99cb099e3ad809f93b8bf6501039de), uint256(0x16857d4f10e4e0aab637c130b7dd02181679b6cdd881d3e7b13628b59c785d53));
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
