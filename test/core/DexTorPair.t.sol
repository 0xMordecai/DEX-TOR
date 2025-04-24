// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DexTorPairTest is Test {
    DexTorPair public dexTorPair;
    address weth = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81; // token0
    address wbtc = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // token1
    address factory = makeAddr("factory");

    function setUp() public {
        // Mint mock tokens
        ERC20Mock(weth).mint(address(this), 100 ether);
        // Deploy DexTorPair
        dexTorPair = new DexTorPair(
            address(weth),
            address(wbtc),
            address(factory)
        );
    }

    /*//////////////////////////////////////////////////////////////
                           CONSTRUCTOR TESTS
    //////////////////////////////////////////////////////////////*/
    function testDeployment() public view {
        // Check token addresses
        assertEq(dexTorPair.getToken0(), weth);
        assertEq(dexTorPair.getToken1(), wbtc);
        // Check factory address
        assertEq(dexTorPair.getFactory(), factory);
    }

    /*//////////////////////////////////////////////////////////////
                           Mint TESTS
    //////////////////////////////////////////////////////////////*/
}
