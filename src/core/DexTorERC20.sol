// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DexTorERC20 is ERC20, ERC20Permit, ERC20Burnable, Ownable {
    error DexTorERC20__ZeroAddress();
    error DexTorERC20__MustBeMoreThanZero();
    error DexTorERC20__BurnAmountExceedsBalance();

    constructor()
        ERC20("DexTor", "DTR")
        ERC20Permit("DexTor")
        Ownable(msg.sender)
    {}

    /**
     * @notice mint is a virtual function from 'ERC20' contract
     * @dev This function allows the caller to mint a specified amount of tokens
     * to a specified address.
     * @param _to address to mint tokens to
     * @param _amount amount of tokens to mint
     */
    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DexTorERC20__ZeroAddress();
        }
        if (_amount <= 0) {
            revert DexTorERC20__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }

    /**
     * @notice burn is a virtual function from 'ERC20Burnable' contract
     * @param _amount amount of tokens to burn
     * @dev This function allows the caller to burn a specified amount of tokens from their own balance.
     */
    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DexTorERC20__MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert DexTorERC20__BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }

    /**
     * @dev This function returns the total supply of tokens in existence.
     */
    function getTotalSupply() external view returns (uint256) {
        return totalSupply();
    }

    /**
     * @dev This function returns the balance of a specified account.
     * @param _account address of the account to check the balance of
     */
    function getBalanceOf(address _account) external view returns (uint256) {
        return balanceOf(_account);
    }
}
