// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/RentalVault.sol";
import "../src/PriceFeed.sol";
import "../src/LootVRF.sol";

contract ConfigureRolesSepolia is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        address timelock = 0xb126D03D6D3426D85a6F77B2110D6E5a15e9F377;
        RentalVault vault = RentalVault(payable(0x8d7A7217fb714624c215b9a6925a3c9fdAD94D07));
        PriceFeed feed = PriceFeed(0xb4719C9C05D6e7E81007824EEcdbe03f9435c337);
        GameItem item = GameItem(0xA710612fe06503CBc502Ef5A364b253c804BD3d5);
        LootVRF loot = LootVRF(0x46518134D22fce2A5314F8326f11B616C8d76455);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Transfer Ownable contracts to Timelock
        vault.transferOwnership(timelock);
        feed.transferOwnership(timelock);

        // 2. Setup LootVRF roles (timelock = admin, revoke deployer)
        loot.grantRole(0x00, timelock);
        loot.revokeRole(0x00, deployer);

        // 3. Revoke deployer administrative/minter/burner/pauser roles on GameItem
        item.revokeRole(item.MINTER_ROLE(), deployer);
        item.revokeRole(item.BURNER_ROLE(), deployer);
        item.revokeRole(item.PAUSER_ROLE(), deployer);
        item.revokeRole(0x00, deployer);

        vm.stopBroadcast();
    }
}
