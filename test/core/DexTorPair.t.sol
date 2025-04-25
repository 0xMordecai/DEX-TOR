// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DexTorERC20} from "src/core/DexTorERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DexTorPairTest is Test {
    DexTorPair public dexTorPair;
    DexTorERC20 dexTorERC20;
    address weth = 0xdd13E55209Fd76AfE204dBda4007C227904f0a81; // token0
    address wbtc = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // token1
    address factory = makeAddr("factory");
    address user = makeAddr("user");

    function setUp() public {
        bytes32 salt = keccak256(abi.encodePacked(weth, wbtc));
        // Deploy DexTorPair
        dexTorPair = new DexTorPair{salt: salt}(
            address(weth),
            address(wbtc),
            address(factory)
        );
        vm.deal(user, 100 ether);
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
    function testMint() public {
        uint256 amount0 = 1e18; // 1 WETH
        uint256 amount1 = 4e8; // 4 WBTC
        vm.startPrank(user);
        IERC20(weth).transfer(address(dexTorPair), amount0);
        IERC20(wbtc).transfer(address(dexTorPair), amount1);
        vm.stopPrank();
        uint liquidity = IDexTorPair(address(dexTorPair)).mint(user);
        console.log("liquidty: ", liquidity);
    }
}
