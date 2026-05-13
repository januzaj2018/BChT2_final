// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/VRFCoordinatorV2Interface.sol";
import "./interfaces/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./GameItem.sol";

contract LootVRF is VRFConsumerBaseV2, AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    VRFCoordinatorV2Interface immutable COORDINATOR;
    GameItem public immutable gameItem;

    uint64 immutable s_subscriptionId;
    bytes32 immutable s_keyHash;
    uint32 constant CALLBACK_GAS_LIMIT = 500_000;
    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        address user;
        uint256 randomWord;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    event LootRequested(uint256 indexed requestId, address indexed user);
    event LootFulfilled(uint256 indexed requestId, address indexed user, uint256 itemId);

    constructor(address _vrfCoordinator, address _gameItem, uint64 _subscriptionId, bytes32 _keyHash)
        VRFConsumerBaseV2(_vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        gameItem = GameItem(_gameItem);
        s_subscriptionId = _subscriptionId;
        s_keyHash = _keyHash;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function requestLootDrop(address user) external onlyRole(OPERATOR_ROLE) returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash, s_subscriptionId, REQUEST_CONFIRMATIONS, CALLBACK_GAS_LIMIT, NUM_WORDS
        );

        s_requests[requestId] = RequestStatus({fulfilled: false, exists: true, user: user, randomWord: 0});

        emit LootRequested(requestId, user);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        RequestStatus storage request = s_requests[requestId];
        require(request.exists, "Request not found");

        request.fulfilled = true;
        request.randomWord = randomWords[0];

        // Map to 1-10 items
        uint256 itemId = (randomWords[0] % 10) + 1;
        gameItem.mint(request.user, itemId, 1, "");

        emit LootFulfilled(requestId, request.user, itemId);
    }
}
