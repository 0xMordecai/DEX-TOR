// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDexTorERC20 {
    function mint(address _to, uint256 _amount) external returns (bool);

    function burn(uint256 _amount) external;

    function getTotalSupply() external view returns (uint256);

    function getBalanceOf(address _account) external view returns (uint256);
}
