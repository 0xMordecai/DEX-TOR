// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {DexTorERC20, Ownable} from "src/core/DexTorERC20.sol";
import {IDexTorERC20} from "src/core/interfaces/IDexTorERC20.sol";

contract DexTorERC20Test is Test {
    DexTorERC20 public dexTorERC20;
    IDexTorERC20 public iDexTorERC20;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");
    address public zeroAddress = address(0);
    uint256 public mintAmount = 1e6;
    uint256 public burnAmount = 1e5;

    function setUp() public {
        vm.startPrank(owner);

        dexTorERC20 = new DexTorERC20();
        iDexTorERC20 = IDexTorERC20(address(dexTorERC20));

        vm.stopPrank();
    }

    ////////////////////////////////////////
    //////////// Mint Test ////////////////
    //////////////////////////////////////
    function test_mintRevertIfZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert(DexTorERC20.DexTorERC20__ZeroAddress.selector);
        iDexTorERC20.mint(zeroAddress, mintAmount);
        vm.stopPrank();
    }

    function test_mintRevertIfAmountIsZero() public {
        vm.startPrank(owner);
        vm.expectRevert(DexTorERC20.DexTorERC20__MustBeMoreThanZero.selector);
        iDexTorERC20.mint(user, 0);
        vm.stopPrank();
    }

    function test_mint() public {
        vm.startPrank(owner);
        iDexTorERC20.mint(user, mintAmount);
        assertEq(dexTorERC20.balanceOf(user), mintAmount);
        vm.stopPrank();
    }
}
