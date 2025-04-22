// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDexTorPair {
    /**
     * @notice Returns the current reserves of the pair.
     * @return _reserve0 The reserve of token0.
     * @return _reserve1 The reserve of token1.
     * @return _blockTimestampLast The last block timestamp when reserves were updated.
     */
    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

    /**
     * @notice Mints liquidity tokens for the given address.
     * @param to The address to receive the minted liquidity tokens.
     * @return liquidity The amount of liquidity tokens minted.
     */
    function mint(address to) external returns (uint liquidity);

    /**
     * @notice Burns liquidity tokens and returns the underlying tokens to the specified address.
     * @param to The address to receive the underlying tokens.
     * @return amount0 The amount of token0 returned.
     * @return amount1 The amount of token1 returned.
     */
    function burn(address to) external returns (uint amount0, uint amount1);

    /**
     * @notice Executes a token swap between token0 and token1.
     * @param amount0Out The amount of token0 to send to the recipient.
     * @param amount1Out The amount of token1 to send to the recipient.
     * @param to The address to receive the output tokens.
     * @param data Additional data to be passed to the recipient for callback execution.
     */
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    /**
     * @notice Forces the balances to match the reserves by transferring excess tokens to the specified address.
     * @param to The address to receive the excess tokens.
     */
    function skim(address to) external;

    /**
     * @notice Forces the reserves to match the current balances of the contract.
     */
    function sync() external;

    /**
     * @notice Returns the address of token0 in the pair.
     * @return The address of token0.
     */
    function token0() external view returns (address);

    /**
     * @notice Returns the address of token1 in the pair.
     * @return The address of token1.
     */
    function token1() external view returns (address);

    /**
     * @notice Returns the address of the factory that created the pair.
     * @return The address of the factory.
     */
    function factory() external view returns (address);

    /**
     * @notice Returns the cumulative price of token0.
     * @return The cumulative price of token0.
     */
    function price0CumulativeLast() external view returns (uint);

    /**
     * @notice Returns the cumulative price of token1.
     * @return The cumulative price of token1.
     */
    function price1CumulativeLast() external view returns (uint);

    /**
     * @notice Returns the last k value (reserve0 * reserve1) after the most recent liquidity event.
     * @return The last k value.
     */
    function kLast() external view returns (uint);
}
