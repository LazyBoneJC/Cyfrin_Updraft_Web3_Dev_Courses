// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract SimpleStorage {
    uint256 favorateNumber = 10; // storage variable: it's a state variable that is stored permanently in the blockchain

    function store(uint256 _favorateNumber) public {
        favorateNumber = _favorateNumber;
    }

    // view function: it's a function that doesn't modify the state of the contract
    function retrieve() public view returns (uint256) {
        return favorateNumber;
    }

    // pure function: it's a function that doesn't read or modify the state of the contract
    function retrievePure() public pure returns (uint256) {
        return 777;
    }
}

// Visibility Specifiers
// - 🌎 **`public`**: accessible from both inside the contract and from external contracts
// - 🏠 **`private`**: accessible only within the *current contract*. It does not hide a value but only restricts its access.
// - 🌲 **`external`**: used only for *functions*. Visible only from *outside* the contract.
// - 🏠🏠 **`internal`**: accessible by the current contract and any contracts *derived* from it.

// 1. 📕 Describe the four visibility keywords and their impact on the code.
// Ans: 1. public: 可以在合約內部和外部合約中訪問
//      2. private: 只能在當前合約中訪問
//      3. external: 只能在合約外部訪問
//      4. internal: 可以在當前合約和衍生合約中訪問

// 2. 📕 What's the difference between `view` and `pure`?
// Ans: view函數不會修改合約的狀態，而pure函數不會讀取或修改合約的狀態。
// English: A view function does not modify the state of the contract, while a pure function does not read or modify the state of the contract.

// 3. 📕 In which circumstances a `pure` function will incur gas costs?
// Ans: 當pure函數調用其他函數時，會產生gas費用。
// English: When a pure function calls another function, it will incur gas costs.

// 4. 📕 Explain what a "scope" is and provide an example of an incorrect scope.
// Ans: Scope是變數的可見性範圍。在Solidity中，變數的作用域僅限於當前合約。如果在函數中定義了與合約中的變數同名的變數，則會導致變數的作用域錯誤。
// English: Scope is the visibility of a variable. In Solidity, the scope of a variable is limited to the current contract. If a variable with the same name as a contract variable is defined in a function, it will result in a scope error.

// 5. 📕 What's the difference between a transaction that deploys a contract and a transaction that transfers ETH?
// Ans: 部署合約的交易會在區塊鏈上創建一個新的合約，而轉移ETH的交易則是將ETH從一個帳戶轉移到另一個帳戶。
// English: A transaction that deploys a contract creates a new contract on the blockchain, while a transaction that transfers ETH moves ETH from one account to another.

// 6. 🧑‍💻 Write a contract that features 3 functions:

//    * write a view function that can be accessed only by the current contract
//    (specifier 要用 internal 還是 private? 為什麼? Ans: private, 因為只能在當前合約中訪問)
//     Ans:
//     function retrievePrivate() private view returns (uint256) {
//         return favorateNumber;
//     }

//    * write a pure function that's not accessible within the current contract
//     Ans:
//     function retrievePureExternal() external pure returns (uint256) {
//         return 777;
//     }

//    * write a view function that can be accessed from children's contracts
//     Ans:
//     function retrieveViewInternal() internal view returns (uint256) {
//         return favorateNumber;
//     }
