// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SimpleStorage} from "./SimpleStorage.sol";

contract AddFiveStorage is SimpleStorage {
    function sayHello() public pure returns (string memory) {
        return "hello world!";
    }

    // 若想要改寫繼承contract的function, 需要知道的概念是"Override"
    // 關鍵字：Virtual & Override
    function store(uint256 _newNumber) public override {
        myFavoriteNumber = _newNumber + 5;
    }
}
