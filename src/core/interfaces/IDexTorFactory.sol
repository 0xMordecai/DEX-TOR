// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDexTorFactory {
    /**
     * @notice Creates a new trading pair for two tokens.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @return pair The address of the newly created pair contract.
     */
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    /**
     * @notice Sets the address to receive protocol fees.
     * @param _feeTo The address to set as the fee recipient.
     */
    function setFeeTo(address _feeTo) external;

    /**
     * @notice Sets the address allowed to update the fee recipient.
     * @param _feeToSetter The address to set as the fee setter.
     */
    function setFeeToSetter(address _feeToSetter) external;

    /**
     * @notice Retrieves the address of a trading pair for two tokens.
     * @param tokenA The address of the first token in the pair.
     * @param tokenB The address of the second token in the pair.
     * @return pair The address of the pair contract.
     */
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    /**
     * @notice Retrieves the address of a pair by its index in the list of all pairs.
     * @param index The index of the pair in the list.
     * @return pair The address of the pair contract.
     */
    function getAllPairs(uint index) external view returns (address pair);

    /**
     * @notice Retrieves the total number of pairs created.
     * @return The total number of pairs.
     */
    function allPairsLength() external view returns (uint);

    /**
     * @notice Retrieves the address set to receive protocol fees.
     * @return The address of the fee recipient.
     */
    function getFeeTo() external view returns (address);

    /**
     * @notice Retrieves the address allowed to update the fee recipient.
     * @return The address of the fee setter.
     */
    function getFeeToSetter() external view returns (address);
}
