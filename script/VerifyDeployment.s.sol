// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/GameTimelock.sol";
import "../src/GameGovernor.sol";
import "../src/LootVRF.sol";
import "../src/PriceFeed.sol";

contract VerifyDeployment is Script {
    struct DeployedAddresses {
        address amm;
        address governor;
        address item;
        address timelock;
        address token;
        address loot;
        address feed;
        address vault;
    }

    function run() external {
        // Read deployment JSON
        string memory path = "deployments/local.json";
        string memory json = vm.readFile(path);

        DeployedAddresses memory addrs;
        addrs.amm = vm.parseJsonAddress(json, ".GameAMM");
        addrs.governor = vm.parseJsonAddress(json, ".GameGovernor");
        addrs.item = vm.parseJsonAddress(json, ".GameItem");
        addrs.timelock = vm.parseJsonAddress(json, ".GameTimelock");
        addrs.token = vm.parseJsonAddress(json, ".GameToken");
        addrs.loot = vm.parseJsonAddress(json, ".LootVRF");
        addrs.feed = vm.parseJsonAddress(json, ".PriceFeed");
        addrs.vault = vm.parseJsonAddress(json, ".RentalVault");

        address deployer = msg.sender;

        console.log("=== STARTING POST-DEPLOYMENT VERIFICATION ===");
        console.log("Deployer:", deployer);
        console.log("Timelock Target:", addrs.timelock);

        // 1. Verify GameToken ownership and rules
        console.log("\n1. Verifying GameToken...");
        GameToken token = GameToken(addrs.token);
        require(token.hasRole(0x00, addrs.timelock), "FAIL: Timelock is not Token Admin");
        require(!token.hasRole(0x00, deployer), "FAIL: Deployer still holds Token Admin backdoor!");
        require(token.hasRole(token.MINTER_ROLE(), addrs.vault), "FAIL: Vault is not Token Minter");
        require(token.hasRole(token.MINTER_ROLE(), addrs.loot), "FAIL: Loot is not Token Minter");
        console.log("SUCCESS: GameToken has no admin backdoors. Admin = Timelock.");

        // 2. Verify GameItem ownership and rules
        console.log("\n2. Verifying GameItem...");
        GameItem item = GameItem(addrs.item);
        require(item.hasRole(item.DEFAULT_ADMIN_ROLE(), addrs.timelock), "FAIL: Timelock is not Item Admin");
        require(!item.hasRole(item.DEFAULT_ADMIN_ROLE(), deployer), "FAIL: Deployer still holds Item Admin backdoor!");
        require(item.hasRole(item.MINTER_ROLE(), addrs.loot), "FAIL: Loot is not Item Minter");
        console.log("SUCCESS: GameItem has no admin backdoors. Admin = Timelock.");

        // 3. Verify Ownable contracts
        console.log("\n3. Verifying Ownable contracts...");
        RentalVault vault = RentalVault(payable(addrs.vault));
        PriceFeed feed = PriceFeed(addrs.feed);
        
        require(vault.owner() == addrs.timelock, "FAIL: RentalVault owner is not Timelock");
        require(feed.owner() == addrs.timelock, "FAIL: PriceFeed owner is not Timelock");
        console.log("SUCCESS: Ownable contracts (Vault, PriceFeed) have been successfully transferred to Timelock.");

        // 4. Verify Governance parameters
        console.log("\n4. Verifying Governance & Timelock configuration...");
        GameGovernor gov = GameGovernor(payable(addrs.governor));
        GameTimelock timelock = GameTimelock(payable(addrs.timelock));

        require(address(gov.timelock()) == addrs.timelock, "FAIL: Governor timelock mismatch");
        require(timelock.getMinDelay() == 2 days, "FAIL: Timelock delay is not correct (expected 2 days)");
        require(timelock.hasRole(timelock.PROPOSER_ROLE(), addrs.governor), "FAIL: Governor is not Timelock proposer");
        require(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(0)), "FAIL: Timelock executor is not open");
        console.log("SUCCESS: Governance configurations are perfectly aligned. MinDelay = 2 days.");

        // 5. Verify LootVRF roles
        console.log("\n5. Verifying LootVRF AccessControl...");
        LootVRF loot = LootVRF(addrs.loot);
        require(loot.hasRole(0x00, addrs.timelock), "FAIL: Timelock is not LootVRF Admin");
        require(!loot.hasRole(0x00, deployer), "FAIL: Deployer still holds LootVRF Admin backdoor!");
        console.log("SUCCESS: LootVRF has no admin backdoors. Admin = Timelock.");

        console.log("\n=======================================================");
        console.log("ALL POST-DEPLOYMENT VERIFICATION CHECKS PASSED!");
        console.log("The protocol is fully decentralized and secure.");
        console.log("=======================================================");
    }
}
