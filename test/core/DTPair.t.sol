// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {ERC20Mock} from "test/mock/ERC20Mock.sol";

contract DexTorPairAddLiquidityTest is Test {
    DexTorPair public dexTorPair;
    ERC20Mock public token0;
    ERC20Mock public token1;
    address public user;
    address public factory;

    function setUp() public {
        // Deploy mock tokens
        token0 = new ERC20Mock("Token0", "TK0", msg.sender, 1e24); // 1 million tokens
        token1 = new ERC20Mock("Token1", "TK1", msg.sender, 1e24); // 1 million tokens

        // Set up addresses
        user = makeAddr("user");
        factory = makeAddr("factory");

        // Deploy DexTorPair
        dexTorPair = new DexTorPair(address(token0), address(token1), factory);

        // Fund user with tokens
        token0.mint(user, 1e20); // 100 tokens
        token1.mint(user, 1e20); // 100 tokens
    }

    function testAddLiquidityInitial() public {
        uint256 amount0 = 1e18; // 1 Token0
        uint256 amount1 = 1e18; // 1 Token1
        console.log("one -----------");
        // User approves DexTorPair to spend tokens
        vm.startPrank(user);
        token0.approve(address(dexTorPair), amount0);
        token1.approve(address(dexTorPair), amount1);
        console.log("two -----------");
        // Transfer tokens to DexTorPair
        token0.transfer(address(dexTorPair), amount0);
        token1.transfer(address(dexTorPair), amount1);
        console.log("three -----------");
        // Call mint to add liquidity
        uint256 liquidity = dexTorPair.mint(user);
        vm.stopPrank();
        console.log("four -----------");
        // Assert liquidity minted
        assertGt(liquidity, 0, "Liquidity should be greater than 0");
        console.log("five -----------");
        // Assert reserves updated
        (uint112 reserve0, uint112 reserve1, ) = dexTorPair.getReserves();
        assertEq(reserve0, amount0, "Reserve0 should match amount0");
        assertEq(reserve1, amount1, "Reserve1 should match amount1");
    }

    function testAddLiquidityExistingPool() public {
        uint256 initialAmount0 = 1e18; // 1 Token0
        uint256 initialAmount1 = 1e18; // 1 Token1
        uint256 additionalAmount0 = 5e17; // 0.5 Token0
        uint256 additionalAmount1 = 5e17; // 0.5 Token1

        // Add initial liquidity
        vm.startPrank(user);
        token0.approve(address(dexTorPair), initialAmount0);
        token1.approve(address(dexTorPair), initialAmount1);
        token0.transfer(address(dexTorPair), initialAmount0);
        token1.transfer(address(dexTorPair), initialAmount1);
        dexTorPair.mint(user);
        vm.stopPrank();

        // Add additional liquidity
        vm.startPrank(user);
        token0.approve(address(dexTorPair), additionalAmount0);
        token1.approve(address(dexTorPair), additionalAmount1);
        token0.transfer(address(dexTorPair), additionalAmount0);
        token1.transfer(address(dexTorPair), additionalAmount1);
        uint256 additionalLiquidity = dexTorPair.mint(user);
        vm.stopPrank();

        // Assert additional liquidity minted
        assertGt(
            additionalLiquidity,
            0,
            "Additional liquidity should be greater than 0"
        );

        // Assert reserves updated
        (uint112 reserve0, uint112 reserve1, ) = dexTorPair.getReserves();
        assertEq(
            reserve0,
            initialAmount0 + additionalAmount0,
            "Reserve0 should match total amount0"
        );
        assertEq(
            reserve1,
            initialAmount1 + additionalAmount1,
            "Reserve1 should match total amount1"
        );
    }

    function testMintRevertsOnZeroBalances() public {
        vm.startPrank(user);

        // Attempt to mint without transferring tokens
        vm.expectRevert("DexTorPair__ZeroBalances");
        dexTorPair.mint(user);

        vm.stopPrank();
    }

    function testMintRevertsOnZeroLiquidity() public {
        uint256 amount0 = 1; // Insufficient Token0
        uint256 amount1 = 1; // Insufficient Token1

        vm.startPrank(user);
        token0.approve(address(dexTorPair), amount0);
        token1.approve(address(dexTorPair), amount1);
        token0.transfer(address(dexTorPair), amount0);
        token1.transfer(address(dexTorPair), amount1);

        // Expect revert due to zero liquidity
        vm.expectRevert("DexTorPair__ZeroLiquidity");
        dexTorPair.mint(user);

        vm.stopPrank();
    }
}
