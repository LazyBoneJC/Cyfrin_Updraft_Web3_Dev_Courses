// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Basic types in Solidity
// * Boolean (bool): true or false
// * Unsigned Integer (uint): unsigned whole number (positive)
// * Integer (int): signed whole number (positive and negative)
// * Address (address): 20 bytes value. An example of an address can be found within your MetaMask account.
// * Bytes (bytes): low-level raw byte data

contract SimpleStorage {
    // Basic types
    bool hasFavorateNumber = true;
    uint256 favorateNumber = 10;
    string favorateString = "String";
    int256 favorateInt = -10;
    address favorateAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    bytes32 favorateBytes = "bytes";

    // Bytes and Strings
    // bytes1 minBytes = "I am a fixed size byte array of 1 byte";
    // bytes32 maxBytes = "I am a fixed size byte array of 32 bytes";
    bytes dynamicBytes = "I am a dynamic array, so you can manipulate my size";

    // The contract logic
    // 👀❗IMPORTANT: Every variable in Solidity comes with a default value.
    // Uninitialized uint256 for example, defaults to `0` (zero) and an uninitialized boolean defaults to `false`.
    uint256 number; // defaults to 0
}

// 1. 📕 What's the difference between a variable and a value?
// Ans: A variable is a named storage location that can store a value. A value is the actual data that is stored in a variable.

// 2. 📕 Describe the default value of the following types: bool, uint, int256, string, address, bytes, bytes32
// Ans: 1.bool: false
//      2.uint: 0
//      3.int256: 0
//      4.string: ""
//      5.address: 0x0
//      6.bytes: ""
//      7.bytes32: "" (長度為32的空字串)

// 3. 📕 How does uint differ from bytes?
// Ans: uint is an unsigned integer that can store whole numbers (positive) while bytes is a low-level raw byte data.

// 4. 🧑‍💻 Write a smart contract that contains at least five storage variables, each with a distinct data type.
// Ans:
// pragma solidity 0.8.19;

// contract DataTypes {
//     bool isReady = true;
//     uint256 number = 10;
//     string name = "Alice";
//     int256 balance = -10;
//     address owner = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
// }
