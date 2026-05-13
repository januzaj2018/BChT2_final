// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/interfaces/AggregatorV3Interface.sol";
import "../src/interfaces/VRFCoordinatorV2Interface.sol";

contract MockAggregatorV3 is AggregatorV3Interface {
    int256 private _price;
    uint8 private _decimals;
    uint256 public updatedAt;

    constructor(int256 initialPrice, uint8 decimals_) {
        _price = initialPrice;
        _decimals = decimals_;
        updatedAt = block.timestamp;
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
        updatedAt = block.timestamp;
    }

    function setUpdatedAt(uint256 _updatedAt) external {
        updatedAt = _updatedAt;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function description() external view returns (string memory) {
        return "Mock Aggregator";
    }

    function version() external view returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (_roundId, _price, block.timestamp, updatedAt, _roundId);
    }

    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (1, _price, block.timestamp, updatedAt, 1);
    }
}

contract MockVRFCoordinatorV2 is VRFCoordinatorV2Interface {
    uint256 private nextRequestId = 1;
    mapping(uint256 => address) private requests;

    function requestRandomWords(
        bytes32,
        uint64,
        uint16,
        uint32,
        uint32
    ) external returns (uint256) {
        uint256 requestId = nextRequestId++;
        requests[requestId] = msg.sender;
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        address consumer = requests[requestId];
        (bool success, ) = consumer.call(
            abi.encodeWithSignature("rawFulfillRandomWords(uint256,uint256[])", requestId, randomWords)
        );
        require(success, "Fulfillment failed");
    }

    function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory) { return (0, 0, new bytes32[](0)); }
    function createSubscription() external returns (uint64) { return 1; }
    function getSubscription(uint64) external view returns (uint96, uint64, uint64, address, address[] memory) {
        return (10**18, 0, 0, address(0), new address[](0));
    }
    function requestSubscriptionOwnerTransfer(uint64, address) external {}
    function acceptSubscriptionOwnerTransfer(uint64) external {}
    function addConsumer(uint64, address) external {}
    function removeConsumer(uint64, address) external {}
    function cancelSubscription(uint64, address) external {}
    function pendingRequestExists(uint64) external view returns (bool) { return false; }
}
