// Develop a decentralized social media platform where users can create and
// share content in the form of NFTs representing multimedia assets such as
// images, videos, and audio clips. The platform should incorporate advanced
// features such as user authentication, role-based access control (RBAC),
// and content moderation.

// Features:
// Integrate an authentication mechanism to verify the identity of users.
// Ensure you make use of factory contracts for the NFT creation features
// All NFT interactions must be done via the social media contract.
// Implement role-based access control (RBAC) to manage permissions for different user roles.
// Ensure that sensitive functions are only accessible to authorized users.
// Implement the creation of groups/ communities on the platform
// Implement features for users to discover and interact with content, including searching, and commenting on NFTs.
// Implement a gasless transaction mechanism whereby users do not pay for gas while using the platform
// Deploy to a testnet and ensure your contract is verified.
// ALL FEATURES SHOULD BE IMPLEMENTED WITH SOLIDITY (NO DAPP)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTS.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface INFTSFactory {
    function createNFTContract(
        address _initialOwner,
        string memory name,
        string memory symbol
    ) external returns (NFTS newContract_, uint length_);

    function mint(
        address to,
        string memory uri
    ) external returns (uint tokenId);
}

contract SocialMedia {
    address nftAddress;

    address owner;

    constructor(address _nftAddress) {
        owner = msg.sender;
        nftAddress = _nftAddress;
    }

    struct User {
        uint id;
        string username;
        string bio;
        string profilePicture;
        address[] followers;
        address[] following;
        bool isAdmin;
        bool isModerator;
    }

    struct Group {
        uint256 id;
        string name;
        address[] members;
    }

    struct Post {
        uint id;
        string tokenUri;
        string content;
        bool isVerified;
        address owner;
        string comments;
        uint likes;
        uint postCount;
    }

    enum Role {
        Admin,
        Moderator
    }

    uint userid;
    uint groupCounts;

    Post[] verifiedPosts;
    Post[] allPosts;
    User[] usersArray;
    Group[] groupArray;

    mapping(address => mapping(address => bool)) isFollowing;

    mapping(address => User) user;

    mapping(address => mapping(uint => Post)) userPosts;

    mapping(address => bool) hasRegistered;

    mapping(address => mapping(uint => bool)) hasLiked;
    mapping(address => mapping(uint => bool)) hasCommented;

    mapping(uint256 => Group) groups;

    mapping(address => bool) isGroupMember;

    mapping(address => mapping(Role => bool)) hasRole;

    event GroupCreated(uint256 id, string name);

    function registerUser(string memory _username, string memory _bio) public {
        require(bytes(_username).length > 0, "Username cannot be empty");

        require(msg.sender != address(0), "Address zero detected");

        require(!hasRegistered[msg.sender], "Have already registered");

        uint _id = userid + 1;

        hasRegistered[msg.sender] = true;

        User storage newUser = user[msg.sender];

        newUser.id = _id;
        newUser.username = _username;
        newUser.bio = _bio;

        userid++;

        usersArray.push(newUser);

        INFTSFactory(nftAddress).createNFTContract(msg.sender, _bio, _username);
    }

    function grantRole(Role _roleType, address _account) external {
        onlyOwner();

        require(hasRegistered[_account], "not a valid user address");

        if (_roleType == Role.Admin) {
            require(!hasRole[_account][Role.Admin], "already has a role");

            User storage newAdmin = user[_account];

            newAdmin.isAdmin = true;
            hasRole[_account][Role.Admin] = true;
        }
        if (_roleType == Role.Moderator) {
            require(!hasRole[_account][Role.Moderator], "already has a role");

            User storage newAdmin = user[_account];

            newAdmin.isModerator = true;
            hasRole[_account][Role.Moderator] = true;
        } else {
            revert("no role available");
        }
    }

    function revokeRole(address _account) external {
        onlyOwner();

        require(hasRegistered[_account], "not a valid user address");

        User storage revoke = user[_account];

        revoke.isModerator = false;
        revoke.isModerator = false;

        hasRole[_account][Role.Moderator] = false;
        hasRole[_account][Role.Admin] = false;
    }

    // Users Create Post from NFT factory contract
    function createPost(
        string memory _content,
        string memory _tokenUri
    ) public {
        require(msg.sender != address(0), "Address zero detected");

        require(
            hasRegistered[msg.sender],
            "Register to be able to create post"
        );

        uint id = INFTSFactory(nftAddress).mint(msg.sender, _tokenUri);

        Post storage post = userPosts[msg.sender][id];

        post.id = id;
        post.content = _content;
        post.tokenUri = _tokenUri;
        post.owner = msg.sender;
        post.postCount = post.postCount + 1;

        allPosts.push(post);
    }

    function verifyPost(uint _id, address _user) external {
        onlyModerator();
        Post storage post = userPosts[_user][_id];
        require(!post.isVerified, "already verified");

        post.isVerified = true;

        verifiedPosts.push(post);
    }

    function moderatorGetAllPost() external view returns (Post[] memory) {
        onlyModerator();
        return allPosts;
    }

    function UsersgetPosts() external view returns (Post[] memory) {
        return verifiedPosts;
    }

    function likePost(uint256 _postId, address _postOwner) external {
        require(hasRegistered[msg.sender], "Register to be able to like post");

        require(!hasLiked[msg.sender][_postId], "already liked post");

        Post storage post = userPosts[_postOwner][_postId];

        post.likes = post.likes + 1;

        hasLiked[msg.sender][_postId] = true;
    }

    function commentOnPost(
        uint256 _postId,
        address _postOwner,
        string memory _comment
    ) external {
        require(
            hasRegistered[msg.sender],
            "Register to be able to comment on post"
        );

        require(!hasCommented[msg.sender][_postId], "already liked post");

        Post storage post = userPosts[_postOwner][_postId];

        post.comments = _comment;

        hasCommented[msg.sender][_postId] = true;
    }

    function followUser(address _userToFollow) public {
        require(
            bytes(user[_userToFollow].username).length > 0,
            "User not registered"
        );

        require(!isFollowing[msg.sender][_userToFollow], "Already following");

        user[msg.sender].following.push(_userToFollow);

        isFollowing[msg.sender][_userToFollow] = true;

        user[_userToFollow].followers.push(msg.sender);
    }

    function createGroup(string calldata name) external {
        onlyAdmin();

        uint256 groupId = groupArray.length;

        groups[groupId] = Group(groupId, name, new address[](0));

        groupArray.push((groups[groupId]));

        emit GroupCreated(groupId, name);
    }

    function joinGroup(uint256 groupId) external {
        require(
            hasRegistered[msg.sender],
            "Register to be able to comment on post"
        );

        require(groups[groupId].id != 0, "Group does not exist");

        require(!isGroupMember[msg.sender], "already a member");

        groups[groupId].members.push(msg.sender);

        isGroupMember[msg.sender] = true;
    }

    function getGroups() external view returns (Group[] memory) {
        return groupArray;
    }

    // Only users with the Moderator Role can validate post
    function onlyAdmin() private view {
        require(
            hasRole[msg.sender][Role.Admin],
            "Restricted to content creators"
        );
    }

    // Only users with the Admin role can create groups
    function onlyModerator() private view {
        require(
            hasRole[msg.sender][Role.Moderator],
            "Restricted to moderators"
        );
    }

    //only admin
    function onlyOwner() private view {
        require(msg.sender == address(0), "no zero address call");

        require(msg.sender == owner, "not authorized");
    }
}
