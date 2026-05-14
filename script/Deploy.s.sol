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
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
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
}
