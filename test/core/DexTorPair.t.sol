// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    address weth = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81; // token0
    address wbtc = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // token1
    address factory = makeAddr("factory");

    function setUp() public {
        // Deploy mock tokens

        // Deploy DexTorPair
        dexTorPair = new DexTorPair(
            address(weth),
            address(wbtc),
            address(factory)
        );
    }

    function testDeployment() public {
        // Check token addresses
        assertEq(dexTorPair.getToken0(), weth);
        assertEq(dexTorPair.getToken1(), wbtc);
        // Check factory address
        assertEq(dexTorPair.getFactory(), factory);
    }
}
