// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // 創建一個測試用戶地址
    uint256 constant SEND_VALUE = 0.1 ether; // 定義一個常量，表示發送的 ETH 數量
    uint256 constant STARTING_BALANCE = 10 ether; // 定義一個常量，表示測試用戶的初始餘額
    uint256 constant GAS_PRICE = 1 gwei; // 定義一個常量，表示測試用戶的 gas 價格

    // This is a setup function that runs before each test
    function setUp() external {
        // 重新部署一份 FundMe 合約，確保每個測試都是從乾淨狀態開始
        // Us -> FundMeTest -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // 給 USER 地址一些初始 ETH
        console.log("FundMe contract deployed at:", address(fundMe));
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(
            fundMe.getOwner(),
            msg.sender,
            "The owner should be the address that deployed the contract"
        );
        // assertEq(
        //     fundMe.i_owner(),
        //     address(this),
        //     "The owner should be the address that deployed the contract"
        // );
    }

    function testPriceFeedVersionIsAccurate() public view {
        // 這個測試會檢查價格餵送器的版本是否正確
        // 這裡我們假設價格餵送器的版本是 4
        uint256 version = fundMe.getVersion();
        assertEq(version, 4, "The price feed version should be 4");
    }

    function testFundFailsWithoutEnoughEth() public {
        // 嘗試在沒有足夠 ETH 的情況下進行資金注入
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund(); // 1 ETH < 5 USD
    }

    function testFundUpdatesFundedDatastructure() public {
        vm.prank(USER); // 模擬 USER 地址進行資金注入(The next tx will be sent by USER)
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(
            amountFunded,
            SEND_VALUE,
            "The amount funded should be updated correctly"
        );
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(
            funder,
            USER,
            "The funder should be added to the array of funders"
        );
    }

    modifier funded() {
        vm.prank(USER); // 模擬 USER 地址進行資金注入
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm.prank(USER); // Simulating USER send transaction
        // fundMe.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert(); // USER is not owner, so expect revert
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange: Setup the test
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act: Action
        // uint256 gasStart = gasleft(); // 記錄 gas 使用量
        // vm.txGasPrice(GAS_PRICE); // 設定交易的 gas 價格
        vm.prank(fundMe.getOwner()); // 模擬合約擁有者進行提款
        fundMe.withdraw();

        // uint256 gasEnd = gasleft(); // 記錄 gas 使用量
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // 計算使用的 gas
        // console.log(gasUsed, "gas used for withdrawal");

        // Assert: 判斷是否符合測試結果
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be zero after withdrawal"
        );
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner's balance should be increased by the FundMe balance"
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // 從 1 開始，0 是 USER
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), SEND_VALUE); // 模擬新的地址進行資金注入
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.startPrank(fundMe.getOwner()); // 模擬合約擁有者進行提款
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(
            address(fundMe).balance,
            0,
            "FundMe balance should be zero after withdrawal"
        );
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance + address(fundMe).balance,
            "Owner's balance should be increased by the FundMe balance"
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // 從 1 開始，0 是 USER
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i), SEND_VALUE); // 模擬新的地址進行資金注入
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.startPrank(fundMe.getOwner()); // 模擬合約擁有者進行提款
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assertEq(
            address(fundMe).balance,
            0,
            "FundMe balance should be zero after withdrawal"
        );
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance + address(fundMe).balance,
            "Owner's balance should be increased by the FundMe balance"
        );
    }
}
