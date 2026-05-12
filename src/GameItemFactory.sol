// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./GameItem.sol";

contract GameItemFactory {
    address public owner;
    address[] public deployedItems;

    event ItemContractDeployed(address indexed itemContract, address indexed deployer);

    constructor() {
        owner = msg.sender;
    }

    function deployGameItem(bytes32 salt) external returns (address) {
        GameItem newItem = new GameItem{salt: salt}();
        deployedItems.push(address(newItem));
        newItem.grantRole(newItem.DEFAULT_ADMIN_ROLE(), msg.sender);
        emit ItemContractDeployed(address(newItem), msg.sender);
        return address(newItem);
    }

    function getDeployedItemsCount() external view returns (uint256) {
        return deployedItems.length;
    }

    function getDeployedItem(uint256 index) external view returns (address) {
        require(index < deployedItems.length, "Index out of bounds");
        return deployedItems[index];
    }
}
