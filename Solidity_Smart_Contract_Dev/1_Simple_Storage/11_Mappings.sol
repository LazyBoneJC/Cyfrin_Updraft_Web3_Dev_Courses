// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

contract SimpleStorage {
    struct Person {
        string name;
        uint256 my_fav_number;
    }

    // Array of Struct
    Person[] public list_of_people; // Dynamic Array

    // list_of_people.add(Person("Pat", 7));
    // list_of_people.add(Person("John", 8));
    // list_of_people.add(Person("Mariah", 10));
    // list_of_people.add(Person("Chelsea", 232));

    // Go through all the people to check their favorite number.
    // If name is "Chelsea" -> return 232

    // Mapping: 把 name 映射到 favorite number 上
    mapping(string => uint256) public name_to_fav_number;

    function add_person(string memory _name, uint256 _favorite_number) public {
        list_of_people.push(Person(_name, _favorite_number));
        name_to_fav_number[_name] = _favorite_number; // 將值存入 mapping 中
    }
}

// 🧑‍💻 Test yourself
1. 📕 In which cases is better to use an array instead of a mapping?

Answer: 
It is better to use an array when you need to store a list of elements that you want to access by index. 
It is better to use a mapping when you need to store key-value pairs and you want to access the value by key.

2. 🧑‍💻 Create a Solidity contract with a mapping named `addressToBalance`. Implement functions to add and retrieve data from this mapping.

Answer:
contract AddressToBalance {
    mapping(address => uint256) public addressToBalance;

    function add_balance(address _address, uint256 _balance) public {
        addressToBalance[_address] = _balance;
    }

    function get_balance(address _address) public view returns (uint256) {
        return addressToBalance[_address];
    }
}