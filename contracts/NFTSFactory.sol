// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./NFTS.sol";

interface INFTS {
    function safeMint(
        address to,
        string memory uri
    ) external returns (uint tokenId);
}

contract NFTSFactory {
    NFTS[] NFTSClones;

    mapping(address => address) public userContract;

    function createNFTContract(
        address _initialOwner
    ) external returns (NFTS newContract_, uint length_) {
        newContract_ = new NFTS(_initialOwner);

        userContract[msg.sender] = address(newContract_);

        NFTSClones.push(newContract_);

        length_ = NFTSClones.length;
    }

    function getUserContracts() public view returns (NFTS[] memory) {
        return NFTSClones;
    }

    function mint(
        address to,
        string memory uri
    ) external returns (uint tokenId) {
        tokenId = INFTS(userContract[msg.sender]).safeMint(to, uri);
    }
}
