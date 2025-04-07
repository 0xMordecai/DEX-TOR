// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract DexTorERC20 is ERC20, ERC20Permit, ERC20Burnable {
    constructor() ERC20("DexTor", "DTR") ERC20Permit("DexTor") {}
}
