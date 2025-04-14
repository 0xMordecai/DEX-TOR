// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDexTorFactory {
    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function getAllPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);
}
