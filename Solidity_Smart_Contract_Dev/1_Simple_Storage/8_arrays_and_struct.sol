// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

contract SimpleStorage {
    // Array and Struct
    // uint256[] list_of_favorite_numbers = [0, 1, 2];

    struct Person {
        uint256 my_fav_number;
        string name;
    }

    // Person public my_friend = Person(666, "Jacky");

    // Array of Struct
    Person[] public list_of_people; // Dynamic Array
    Person[3] public list_of_three_people; // Static Array

    // memory:
    function add_person(uint256 _favorite_number, string memory _name) public {
        list_of_people.push(Person(_favorite_number, _name));
    }
}

// 🧑‍💻 Test yourself

1. 📕 Define the difference between a dynamic array and a static array. Make an example of each.
Answer: dynamic array is an array that can change its size during the execution of the program, while a static array is an array that has a fixed size.
example of dynamic array: uint256[] list_of_favorite_numbers = [0, 1, 2];
example of static array: Person[3] public list_of_three_people;


2. 📕 What is an array and what is a struct?
Answer: An array is a collection of elements of the same type that are stored in a contiguous memory location. 
        A struct is a user-defined data type that groups together variables of different data types.


3. 🧑‍💻 Create a smart contract that can store and view a list of animals. 
Add manually three (3) animals and give the possibility to the user to manually add an indefinite number of animals into the smart contract.
Answer: 
contract AnimalStorage {
    // Step 1: create a struct
    struct Animal {
        uint256 id;
        string name;
    }

    // Step 2: create an array of animals with three animals
    Animal[] public list_of_animals = [
        Animal(1, "Dog"),
        Animal(2, "Cat"),
        Animal(3, "Rabbit")
    ];

    // Step 3: create a function to add an animal
    function addAnimal(uint256 _id, string memory _name) public {
        list_of_animals.push(Animal(_id, _name));
    }
}