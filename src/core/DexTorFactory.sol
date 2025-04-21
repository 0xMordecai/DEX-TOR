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

    /**
     * @notice Creates a new trading pair for two tokens.
     * @dev This function deploys a new `DexTorPair` contract for the given token pair if it doesn't already exist.
     *      It ensures that the tokens are valid and that the pair does not already exist.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @return pair The address of the newly created pair contract.
     * @custom:reverts DexTorFactory__SameTokenAddress if `tokenA` and `tokenB` are the same.
     * @custom:reverts DexTorFactory__ZeroAddress if either `tokenA` or `tokenB` is the zero address.
     * @custom:reverts DexTorFactory__PairExists if a pair for the given tokens already exists.
     * @custom:emits PairCreated event with details of the created pair.
     */
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        // Ensure the two tokens are not the same
        if (tokenA == tokenB) {
            revert DexTorFactory__SameTokenAddress();
        }

        // Sort the token addresses to maintain a consistent order
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        // Ensure the first token address is not the zero address
        if (token0 == address(0)) {
            revert DexTorFactory__ZeroAddress();
        }

        // Check if a pair for the given tokens already exists
        if (TokensPair[token0][token1] != address(0)) {
            revert DexTorFactory__PairExists();
        }

        /**
         * @dev Use a deterministic deployment mechanism with a unique salt.
         * The salt is derived from the hashed combination of the two token addresses.
         */
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        // Deploy the new pair contract using the `DexTorPair` constructor
        pair = address(new DexTorPair{salt: salt}(token0, token1));

        // Store the pair address in the mapping for both token orders
        TokensPair[token0][token1] = pair;
        TokensPair[token1][token0] = pair; // Populate mapping in the reverse direction

        // Add the new pair to the list of all pairs
        allPairs.push(pair);

        // Emit an event to notify that a new pair has been created
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
