// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorFactory} from "src/core/interfaces/IDexTorFactory.sol";

contract DexTorFactory is IDexTorFactory {
    error DexTorFactory__NotFeeToSetter();
    error DexTorFactory__SameTokenAddress();
    error DexTorFactory__ZeroAddress();
    error DexTorFactory__PairExists();

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
    ) external returns (address pair) {
        if (tokenA == tokenB) {
            revert DexTorFactory__SameTokenAddress();
        }
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        if (token0 == address(0)) {
            revert DexTorFactory__ZeroAddress();
        }
        if (TokensPair[token0][token1] != address(0)) {
            revert DexTorFactory__PairExists();
        }
        /**
         * type(UniswapV2Pair).creationCode returns the initialization (creation) bytecode of the UniswapV2Pair contract.
         */
        bytes memory bytecode = type(DexTorPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        pair = address(new DexTorPair{salt: salt}(token0, token1));
        TokensPair[token0][token1] = pair;
        TokensPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

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

    function getFeeTo() external view returns (address) {
        return feeTo;
    }

    function getFeeToSetter() external view returns (address) {
        return feeToSetter;
    }
}
