// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DexTorERC20, ERC20} from "src/core/DexTorERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DexTorPair} from "src/core/DexTorPair.sol";
import {IDexTorPair} from "src/core/interfaces/IDexTorPair.sol";
import {ERC20Mock} from "test/mock/ERC20Mock.sol";

contract DexTorPairTest is Test {
    //events
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    // state variables
    DexTorPair public dexTorPair;
    DexTorERC20 dexTorERC20;
    ERC20Mock token0;
    ERC20Mock token1;
    address factory = makeAddr("factory");
    address user = makeAddr("user");
    bytes32 salt;

    function setUp() public {
        token0 = new ERC20Mock("Token0", "tk0", user, 1e24);
        token1 = new ERC20Mock("Token1", "tk1", user, 1e24);
        salt = keccak256(abi.encodePacked(token0, token1, factory));
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

    function testRevertsIfTokensAddressAreZero() public {
        vm.expectRevert(DexTorPair.DexTorPair__ZeroAddress.selector);
        new DexTorPair{salt: salt}(
            address(0),
            address(token1),
            address(factory)
        );
    }

    function testRevertsIfTokensAddressAreSame() public {
        vm.expectRevert(
            DexTorPair.DexTorPair__TokensHaveSameAddresses.selector
        );
        new DexTorPair{salt: salt}(
            address(token0),
            address(token0),
            address(factory)
        );
    }

    function testRevertsIfFactoryAddressIsZero() public {
        vm.expectRevert(DexTorPair.DexTorPair__FactoryAddressIsZero.selector);
        new DexTorPair{salt: salt}(
            address(token0),
            address(token1),
            address(0)
        );
    }

    // _safeTransfer
    function testRevertsIfSafeTransferFails() public {
        // Transfer tokens to the pair
        token0.transferInternal(user, address(dexTorPair), 1e18);
        token1.transferInternal(user, address(dexTorPair), 1e18);
        // Expect revert when calling _safeTransfer with insufficient balance
        vm.expectRevert(DexTorPair.DexTorPair__TransferFailed.selector);
        dexTorPair._safeTransfer(address(token0), user, 2e18);
    }

    // function _update
    function testRevertsIfBalanceExceedsUnit112Max() public {
        // Transfer tokens to the pair
        token0.transferInternal(user, address(dexTorPair), 1e18);
        token1.transferInternal(user, address(dexTorPair), 1e18);
        // Expect revert when calling _update with balance exceeding uint112 max
        vm.expectRevert(
            DexTorPair.DexTorPair__BalanceExceedsUint112Max.selector
        );
        dexTorPair._update(2 ** 112, 0, 0, 0);
    }

    function testEmitsSyncEventAfterUpdate() public {
        // Transfer tokens to the pair
        token0.transferInternal(user, address(dexTorPair), 1e18);
        token1.transferInternal(user, address(dexTorPair), 1e18);
        // Expect Sync event to be emitted after _update
        vm.expectEmit(true, true, true, true);
        emit Sync(0, 0);
        dexTorPair._update(0, 0, 0, 0);
    }

    /*//////////////////////////////////////////////////////////////
                           Public TESTS
    // //////////////////////////////////////////////////////////////*/
    // function testMint() public {
    //     uint256 amount0 = 1e18; // 1 WETH
    //     uint256 amount1 = 4e8; // 4 WBTC
    //     vm.startPrank(user);
    //     token0.transferInternal(user, address(dexTorPair), amount0);
    //     token1.transferInternal(user, address(dexTorPair), amount1);
    //     vm.stopPrank();
    //     uint liquidity = IDexTorPair(address(dexTorPair)).mint(user);
    //     console.log("liquidty: ", liquidity);
    // }

    /*//////////////////////////////////////////////////////////////
                           GETTERS TESTS
    // //////////////////////////////////////////////////////////////*/

    // function testGetToken0() public view {
    //     assertEq(dexTorPair.getToken0(), address(token0));
    // }

    function testGetToken1() public view {
        assertEq(dexTorPair.getToken1(), address(token1));
    }

    function testGetFactory() public view {
        assertEq(dexTorPair.getFactory(), factory);
    }

    function testGetReserves() public view {
        (uint112 reserve0, uint112 reserve1, ) = dexTorPair.getReserves();
        assertEq(reserve0, 0);
        assertEq(reserve1, 0);
    }

    function testGetTotalSupply() public view {
        uint256 totalSupply = dexTorPair.totalSupply();
        assertEq(totalSupply, 0);
    }
}
