// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// custom errors
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // uint256 public constant MINIMUM_FUNDING_VALUE = 1e18;
    uint256 public constant MINIMUM_USD = 5e18;

    // Create a array to store address who funds the contract
    address[] public funders;

    // Map each funder's address to the amount they sent
    mapping(address funder => uint256 amountFunded)
        public addressToAmountFunded;
    mapping(address funder => uint256 timeContributed)
        public addressToTimeContributed;

    // When the contract is deployed, set the deployer's address as the owner.
    // address public owner;

    // 原始註解：Put an I infront of variable's name, let us know it's a immutable variable.
    // 優化註解：Prefix with "i_" to indicate this is an immutable variable.
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    // Send funds into our contract
    function fund() public payable {
        // require(getConversionRate(msg.value) >= MINIMUM_USD, "Didn't send enough ETH");
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        // getConversionRate 從 Library 導入，而前面的 msg.value 就是要傳入此 function 的值！

        // Track unique funders
        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender);
        }

        addressToAmountFunded[msg.sender] += msg.value;
        addressToTimeContributed[msg.sender] += 1;
    }

    function withdraw() public onlyOwner {
        // 原始版：If sender is not equal owner, refuse to withdraw.
        // 優化版註解：Only the owner can withdraw, revert if called by others.
        // require(msg.sender == owner, "Must be owner!");

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // withdraw the funds

        // transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed.");

        // call (建議用 call)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed.");
    }

    // Implement a function contributionCount to monitor how many times a user calls the fund function to send money to the contract.
    function contributionCount(address funder) public view returns (uint256) {
        require(
            addressToTimeContributed[funder] > 0,
            "Funder has not contributed yet"
        );
        return addressToTimeContributed[funder];
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender not owner!");

        // Replace require with custom error to reduce gas fee.
        if (msg.sender != i_owner) {
            revert NotOwner();
        }

        // 以上是比較新的寫法，require 還是很常見，以下是另一種寫法
        // require(msg.sender != i_owner, NMotOwner());

        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
