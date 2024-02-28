// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

interface ISocialMedia {
    function registerUser(string memory _username, string memory _bio) external;

    function createPost(
        string memory _content,
        string memory _tokenUri
    ) external;
}
