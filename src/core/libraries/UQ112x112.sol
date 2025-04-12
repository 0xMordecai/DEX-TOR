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
