// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract DexTorPair {
    error DexTorPair__ZeroAddress();
    error DexTorPair__TokensHaveSameAddresses();
    error DexTorPair__BurnAmountExceedsBalance();

    address public factory;
    address public immutable token0;
    address public immutable token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

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
}
