// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library UQ112x112 {
    error UQ112x112__DivisionByZero();
    uint224 constant Q112 = 2 ** 112;

    // Encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112;
    }

    // Divide a UQ112x112 by a uint112, returning a uint224(UQ112x112)
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        if (y != 0) {
            revert UQ112x112__DivisionByZero();
        }
        z = x / uint224(y);
    }
}

library Math {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
