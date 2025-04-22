// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {DexTorFactory} from "src/core/DexTorFactory.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {IDexTorFactory} from "src/core/interfaces/IDexTorFactory.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract DexTorPairTest is Test {
    DexTorPair public dexTorPair;
    DexTorFactory public dexTorFactory;
    ERC20Mock public tokenA;
    ERC20Mock public tokenB;
    address public owner;

    function setUp() public {
        owner = makeAddr("owner");

        // Deploy mock tokens
        tokenA = new ERC20Mock("TokenA", "TKA", 1e24);
        tokenB = new ERC20Mock("TokenB", "TKB", 1e24);

        // Deploy factory
        dexTorFactory = new DexTorFactory(owner);
    }
}
