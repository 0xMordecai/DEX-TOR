// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDexTorFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address _feeTo) external;

    function setFeeToSetter(address _feeToSetter) external;

    function getAllPairs(uint index) external view returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function getFeeTo() external view returns (address);

    function getFeeToSetter() external view returns (address);
}
