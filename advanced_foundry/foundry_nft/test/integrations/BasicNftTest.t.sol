// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNft} from "../../script/DeployBasicNft.s.sol";
import {BasicNft} from "../../src/BasicNft.sol";

contract BasicNftTest is Test {
    DeployBasicNft public deployer;
    BasicNft public basicNft;
    address public USER = makeAddr("user");
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        // This function can be used to set up any state before each test
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory actualName = basicNft.name();
        // Solidity 中，String 是 array of bytes，不能直接用 assertEq 比较
        // 因此需要先将字符串转换为 bytes，然后再进行比较
        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(actualName))
        );
        // assertEq(keccak256(abi.encodePacked(actualName)), keccak256(abi.encodePacked(expectedName)), "NFT name should be Dogie");
    }

    function testCanMintAndHaveABalance() public {
        vm.startPrank(USER);
        basicNft.mintNft(PUG_URI);
        assertEq(basicNft.balanceOf(USER), 1, "User should have 1 NFT");
        assertEq(
            keccak256(abi.encodePacked(basicNft.tokenURI(0))),
            keccak256(abi.encodePacked(PUG_URI)),
            "Token URI should match the minted NFT's URI"
        );
        vm.stopPrank();
    }
}
