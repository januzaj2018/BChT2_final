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
 * Refactored to avoid "Stack too deep" errors during coverage reports.
 */
contract DeployScript is Script {
    struct DeployedContracts {
        GameToken token;
        GameItem item;
        PriceFeed feed;
        GameAMM amm;
        RentalVault vault;
        GameTimelock timelock;
        GameGovernor governor;
        LootVRF loot;
    }

    function run() external {
        // Use environment variable if set, otherwise fallback to Anvil's default account #0
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        DeployedContracts memory dc;

        // 1. Core Tokens & Oracle
        dc.token = new GameToken();
        dc.item = new GameItem();
        new GameItemFactory();

        // Use parseAddress to satisfy compiler checksum demands safely
        address ethUsdFeed = vm.parseAddress("0xd30621D869D25c9a81c3129d58d49758A7d078c1");
        dc.feed = new PriceFeed(ethUsdFeed);

        // 2. Marketplace & Vault
        GameToken woodToken = new GameToken();
        dc.amm = new GameAMM(address(dc.token), address(woodToken));
        dc.vault = new RentalVault(dc.token, dc.item, 1);

        // 3. Governance
        {
            address[] memory proposers = new address[](0);
            address[] memory executors = new address[](0);
            dc.timelock = new GameTimelock(2 days, proposers, executors, deployer);
            dc.governor = new GameGovernor(dc.token, dc.timelock);
        }

        // 4. Loot VRF
        address vrfCoordinator = 0x6D1416c43F9cb9F0A70068BB7F2cd9E6A0324310;
        dc.loot = new LootVRF(vrfCoordinator, address(dc.item), 1, bytes32(0));

        // 5. Setup Roles & Ownership
        _setupRoles(dc, deployer);

        vm.stopBroadcast();

        _logAddresses(dc);
        _writeDeploymentJson(dc);
    }

    function _setupRoles(DeployedContracts memory dc, address deployer) internal {
        dc.timelock.grantRole(dc.timelock.PROPOSER_ROLE(), address(dc.governor));
        dc.timelock.grantRole(dc.timelock.EXECUTOR_ROLE(), address(0));

        dc.token.grantRole(dc.token.MINTER_ROLE(), address(dc.vault));
        dc.token.grantRole(dc.token.MINTER_ROLE(), address(dc.loot));
        dc.item.grantRole(dc.item.MINTER_ROLE(), address(dc.loot));
        dc.item.grantRole(dc.item.DEFAULT_ADMIN_ROLE(), address(dc.timelock));

        // Transfer admin to timelock
        dc.token.grantRole(0x00, address(dc.timelock));
        dc.token.revokeRole(0x00, deployer);
    }

    function _logAddresses(DeployedContracts memory dc) internal view {
        console.log("--- DEPLOYMENT LOG ---");
        console.log("GameToken:", address(dc.token));
        console.log("GameItem:", address(dc.item));
        console.log("PriceFeed:", address(dc.feed));
        console.log("GameAMM:", address(dc.amm));
        console.log("RentalVault:", address(dc.vault));
        console.log("GameTimelock:", address(dc.timelock));
        console.log("GameGovernor:", address(dc.governor));
        console.log("LootVRF:", address(dc.loot));
    }

    /**
     * @dev Writes all deployed addresses to deployments/local.json.
     *      The frontend and Justfile sync-addresses command reads this file
     *      so you never have to copy-paste addresses manually.
     */
    function _writeDeploymentJson(DeployedContracts memory dc) internal {
        string memory obj = "output";
        vm.serializeAddress(obj, "GameToken", address(dc.token));
        vm.serializeAddress(obj, "GameItem", address(dc.item));
        vm.serializeAddress(obj, "PriceFeed", address(dc.feed));
        vm.serializeAddress(obj, "GameAMM", address(dc.amm));
        vm.serializeAddress(obj, "RentalVault", address(dc.vault));
        vm.serializeAddress(obj, "GameTimelock", address(dc.timelock));
        vm.serializeAddress(obj, "GameGovernor", address(dc.governor));
        string memory finalJson = vm.serializeAddress(obj, "LootVRF", address(dc.loot));

        // Write to deployments/local.json (relative to project root)
        vm.writeJson(finalJson, "./deployments/local.json");
        console.log("Addresses written to deployments/local.json");
    }
}
