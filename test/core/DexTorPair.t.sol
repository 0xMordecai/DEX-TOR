// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DexTorERC20, ERC20} from "src/core/DexTorERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {ERC20Mock} from "test/mock/ERC20Mock.sol";

contract DexTorPairTest is Test {
    DexTorPair public dexTorPair;
    DexTorERC20 dexTorERC20;
    ERC20Mock token0;
    ERC20Mock token1;
    address wbtc = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // token1
    address factory = makeAddr("factory");
    address user = makeAddr("user");

    function setUp() public {
        token0 = new ERC20Mock("Token0", "tk0", user, 1e24);
        token1 = new ERC20Mock("Token1", "tk1", user, 1e24);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, factory));
        // Deploy DexTorPair
        dexTorPair = new DexTorPair{salt: salt}(
            address(token0),
            address(token1),
            address(factory)
        );
        // Fund user with tokens
        token0.mint(user, 1e20); // 100 tokens
        token1.mint(user, 1e20); // 100 tokens
    }

    /*//////////////////////////////////////////////////////////////
                           CONSTRUCTOR TESTS
    //////////////////////////////////////////////////////////////*/
    function testDeployment() public view {
        // Check token addresses
        assertEq(dexTorPair.getToken0(), address(token0));
        assertEq(dexTorPair.getToken1(), address(token1));
        // Check factory address
        assertEq(dexTorPair.getFactory(), factory);
    }

    /*//////////////////////////////////////////////////////////////
                           Mint TESTS
    //////////////////////////////////////////////////////////////*/
    function testMint() public {
        uint256 amount0 = 1e18; // 1 WETH
        uint256 amount1 = 4e8; // 4 WBTC
        vm.startPrank(user);
        token0.transferInternal(user, address(dexTorPair), amount0);
        token1.transferInternal(user, address(dexTorPair), amount1);
        vm.stopPrank();
        uint liquidity = IDexTorPair(address(dexTorPair)).mint(user);
        console.log("liquidty: ", liquidity);
    }
}
