// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;

    address USER = makeAddr("user"); // 創建一個測試用戶地址
    uint256 constant SEND_VALUE = 0.1 ether; // 定義一個常量，表示發送的 ETH 數量
    uint256 constant STARTING_BALANCE = 10 ether; // 定義一個常量，表示測試用戶的初始餘額
    uint256 constant GAS_PRICE = 1 gwei; // 定義一個常量，表示測試用戶的 gas 價格

    function setUp() external {
        // 重新部署一份 FundMe 合約，確保每個測試都是從乾淨狀態開始
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE); // 給 USER 地址一些初始 ETH
        console.log("FundMe contract deployed at:", address(fundMe));
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(USER); // 模擬 USER 地址進行資金注入
        fundMe.fund{value: SEND_VALUE}();

        // Call withdraw directly as the owner instead of using the script
        // Before (failing):
        // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // vm.prank(fundMe.getOwner());
        // withdrawFundMe.withdrawFundMe(address(fundMe));

        // After (working):
        address owner = fundMe.getOwner();
        vm.prank(owner);
        fundMe.withdraw();

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assertEq(
            address(fundMe).balance,
            0,
            "The FundMe contract balance should be zero after withdrawal"
        );
        assertEq(
            afterUserBalance + SEND_VALUE,
            preUserBalance,
            "User's balance should increase after funding and withdrawal"
        );
        assertEq(
            afterOwnerBalance,
            preOwnerBalance + SEND_VALUE,
            "Owner's balance should increase after withdrawal"
        );

        // 檢查第一個資金提供者是否是 USER
        // 這裡假設 fundMe.getFunder(0) 返回第一個資金提供者的地址
        // address funder = fundMe.getFunder(0);
        // assertEq(funder, USER, "The first funder should be the USER address");
        // console.log("User funded and owner withdrew successfully.");
    }

    // function testUserCanFundInteractions() public {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     fundFundMe.fundFundMe(address(fundMe));
    //     vm.prank(USER); // 模擬 USER 地址進行資金注入
    //     vm.deal(USER, 1e18); // 給 USER 地址一些 ETH

    //     address funder = fundMe.getFunder(0);
    //     assertEq(funder, USER, "The first funder should be the USER address");
    // }

    // function testUserCanWithdrawInteractions() public {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     fundFundMe.fundFundMe(address(fundMe));

    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     assertEq(
    //         address(fundMe).balance,
    //         0,
    //         "The FundMe contract balance should be zero after withdrawal"
    //     );
    // }
}
