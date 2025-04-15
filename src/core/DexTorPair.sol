// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import {UQ112x112, Math} from "src/core/libraries/UQ112x112.sol";
import {IDexTorFactory} from "src/core/interfaces/IDexTorFactory.sol";

contract DexTorPair {
    using UQ112x112 for uint224;
    error DexTorPair__ZeroAddress();
    error DexTorPair__TokensHaveSameAddresses();
    error DexTorPair__BurnAmountExceedsBalance();
    error DexTorPair__LOCKED();
    error DexTorPair__BalanceExceedsUint112Max();

    address public immutable factory;
    address public immutable token0;
    address public immutable token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor(address _token0, address _token1) {
        if (_token0 == address(0) || _token0 == address(0)) {
            revert DexTorPair__ZeroAddress();
        }
        if (_token0 == _token1) {
            revert DexTorPair__TokensHaveSameAddresses();
        }
        token0 = _token0;
        token1 = _token1;
        factory = msg.sender;
    }

    uint256 private unlocked = 1;
    modifier lock() {
        if (unlocked != 1) {
            revert DexTorPair__LOCKED();
        }
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _update(
        uint balance0,
        uint balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) {
            revert DexTorPair__BalanceExceedsUint112Max();
        }
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            unchecked {
                // price of x in term of y
                price0CumulativeLast +=
                    uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                    timeElapsed;
                // price of y in term of x
                price1CumulativeLast +=
                    uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                    timeElapsed;
            }
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;

        emit Sync(reserve0, reserve1);
    }

    /**
     * @dev The _mintFee function calculates and mints liquidity tokens as a fee if certain conditions are met.
     *  The fee is based on the growth in the square root of the product of the reserves (k).
     *  This mechanism is used in Uniswap V2 to ensure that liquidity providers (LPs) are incentivized and properly rewarded when the protocol's fee mechanism is active.
     * @param _reserve0 token0 reserve
     * @param _reserve1 token1 reserve
     * @return feeOn boolean indicating if the fee is on or not
     */
    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        // If the fee mechanism is active (feeOn == true) and _kLast is not zero:
        // Calculate rootK and rootKLast:
        // rootK is the square root of the current product of reserves (_reserve0 * _reserve1).
        // rootKLast is the square root of the previous product of reserves (_kLast).
        // Ensure Growth in Product of Reserves:
        // If rootK (current) is greater than rootKLast (previous), it means the reserves have grown, and liquidity fees need to be minted.
        // Calculate Liquidity:
        // numerator is the product of the total supply of liquidity tokens (totalSupply) and the growth in reserves (rootK - rootKLast).
        // denominator is a weighted sum of the current and previous reserves (rootK * 5 + rootKLast).
        // liquidity is the amount of liquidity tokens to mint, calculated as numerator / denominator.
        // Mint Liquidity:
        // If liquidity > 0, mint the calculated amount of liquidity tokens to the feeTo address.
        address feeTo = IDexTorFactory(factory).getFeeTo();
        if (feeTo != address(0)) {
            feeOn = true;
        } else {
            feeOn = false;
        }
        uint _kLast = kLast;
        if (feeOn && _kLast != 0) {}
    }
}
