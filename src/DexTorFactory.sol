// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import {IDexTorFactory} from "src/core/interfaces/IDexTorFactory.sol";

contract DexTorFactory is IDexTorFactory {
    error DexTorFactory__NotFeeToSetter();
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public TokensPair;
    address[] public allPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint allPairsLength
    );

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    // Still need to implement the createPair function After completing the DexTorPair contract
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {}

    function setFeeTo(address _feeTo) external {
        if (msg.sender != feeToSetter) {
            revert DexTorFactory__NotFeeToSetter();
        }
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        if (msg.sender != feeToSetter) {
            revert DexTorFactory__NotFeeToSetter();
        }
        feeToSetter = _feeToSetter;
    }

    // Getters
    function getAllPairs(uint index) external view returns (address pair) {
        return allPairs[index];
    }

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair) {
        return TokensPair[tokenA][tokenB];
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
}
