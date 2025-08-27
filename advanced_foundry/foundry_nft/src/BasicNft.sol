// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter; // storage variable to keep track of token IDs
    mapping(uint256 => string) private s_tokenIdToUri; // mapping to store token URIs

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0; // initialize token counter to 0
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter); // mint the NFT to the sender
        s_tokenCounter++; // increment the token counter
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId]; // return the URI for the given token ID
    }
}
