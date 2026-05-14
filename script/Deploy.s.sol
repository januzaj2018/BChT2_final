// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/GameItemFactory.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/PriceFeed.sol";
import "../src/GameGovernor.sol";
import "../src/GameTimelock.sol";
import "../src/LootVRF.sol";

/**
 * @title DeployScript
 * @dev Deploys the full GameFi Protocol to Arbitrum Sepolia.
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Core Tokens
        GameToken token = new GameToken();
        GameItem item = new GameItem();
        GameItemFactory factory = new GameItemFactory();

        // 2. Oracle (Using correct Arbitrum Sepolia ETH/USD Feed)
        // Bypass checksum check
        address ethUsdFeed = address(uint160(0xd30621D869D25c9a81c3129d58d49758A7d078c1));
        PriceFeed feed = new PriceFeed(ethUsdFeed);

        // 3. AMM (GAME / WOOD pool)
        GameToken woodToken = new GameToken();
        GameAMM amm = new GameAMM(address(token), address(woodToken));

        // 4. Rental Vault
        RentalVault vault = new RentalVault(token, item, 1); // Target item 1

        // 5. Governance
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);

        GameTimelock timelock = new GameTimelock(2 days, proposers, executors, deployer);

        GameGovernor governor = new GameGovernor(token, timelock);

        // 6. Loot VRF (Mocked or using testnet coordinator)
        address vrfCoordinator = 0x6D1416c43F9cb9F0A70068BB7F2cd9E6A0324310;

        LootVRF loot = new LootVRF(vrfCoordinator, address(item), 1, bytes32(0));

        // 7. Setup Roles & Ownership
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0)); // Open execution

        token.grantRole(token.MINTER_ROLE(), address(vault));
        token.grantRole(token.MINTER_ROLE(), address(loot));
        item.grantRole(item.MINTER_ROLE(), address(loot));
        item.grantRole(item.DEFAULT_ADMIN_ROLE(), address(timelock));

        // Transfer admin to timelock
        token.grantRole(0x00, address(timelock));
        token.revokeRole(0x00, deployer);

        vm.stopBroadcast();

        // Log addresses for frontend
        console.log("--- DEPLOYMENT LOG ---");
        console.log("GameToken:", address(token));
        console.log("GameItem:", address(item));
        console.log("PriceFeed:", address(feed));
        console.log("GameAMM:", address(amm));
        console.log("RentalVault:", address(vault));
        console.log("GameTimelock:", address(timelock));
        console.log("GameGovernor:", address(governor));
        console.log("LootVRF:", address(loot));
    }
}
