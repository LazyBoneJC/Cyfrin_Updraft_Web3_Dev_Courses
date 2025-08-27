// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether; // 100 tokens with 18 decimals

    function setUp() public {
        // This function is called before each test
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // The actual owner is msg.sender
        // vm.prank(address(deployer));
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE); // Transfer 100 tokens to Bob
    }

    function testBobBalance() public view {
        // balanceOf 屬於 ERC20.sol 中的 function
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        // transferFrom -
        // If I want my contract to keep track of tokens it has from you, it needs to be the one that transfer the token from you to itself
        // In order for it to take token from you, you need to allow it to do that.
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend 1000 tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount); // 若使用 transfer() Alice(function caller) 則會變成 from 的地址

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    // ---以下為GPT生成的測試函數---

    function testTotalSupply() public view {
        // 總供應量應等於最初發行量
        assertEq(ourToken.totalSupply(), 1000 ether); // 假設 initialSupply 是 1000 ether
    }

    function testTransferInsufficientBalanceShouldFail() public {
        vm.expectRevert(); // 預期會 revert
        vm.prank(bob);
        ourToken.transfer(alice, 1000 ether); // 超過 bob 餘額
    }

    // function testApproveAndTransferFromShouldDecreaseAllowance() public {
    //     uint256 allowanceAmount = 1000 ether;

    //     vm.prank(bob);
    //     ourToken.approve(alice, allowanceAmount);

    //     vm.prank(alice);
    //     ourToken.transferFrom(bob, alice, 400 ether);

    //     // 應該只剩下 600 allowance
    //     assertEq(ourToken.allowance(bob, alice), 600 ether);
    // }

    function testApproveAndTransferFromShouldDecreaseAllowance() public {
        uint256 allowanceAmount = 100 ether; // match bob's balance

        vm.prank(bob);
        ourToken.approve(alice, allowanceAmount);

        uint256 transferAmount = 40 ether; // smaller than STARTING_BALANCE (100 ether)

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // 驗證 Bob 的 allowance 被扣除
        assertEq(
            ourToken.allowance(bob, alice),
            allowanceAmount - transferAmount
        );

        // 驗證餘額是否正確更新
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferShouldUpdateBalances() public {
        uint256 amount = 20 ether;

        vm.prank(bob);
        ourToken.transfer(alice, amount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - amount);
        assertEq(ourToken.balanceOf(alice), amount);
    }

    function testIncreaseAndDecreaseAllowance() public {
        vm.prank(bob);
        ourToken.approve(alice, 100 ether);

        vm.prank(bob);
        ourToken.increaseAllowance(alice, 50 ether);
        assertEq(ourToken.allowance(bob, alice), 150 ether);

        vm.prank(bob);
        ourToken.decreaseAllowance(alice, 30 ether);
        assertEq(ourToken.allowance(bob, alice), 120 ether);
    }

    function testDecreaseAllowanceBelowZeroShouldFail() public {
        vm.prank(bob);
        ourToken.approve(alice, 20 ether);

        vm.expectRevert();
        vm.prank(bob);
        ourToken.decreaseAllowance(alice, 30 ether);
    }

    function testTransferFromWithInsufficientAllowanceShouldFail() public {
        vm.prank(bob);
        ourToken.approve(alice, 20 ether);

        vm.expectRevert();
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, 30 ether);
    }
}
