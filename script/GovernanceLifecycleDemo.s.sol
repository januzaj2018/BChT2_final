// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/GameGovernor.sol";
import "../src/GameTimelock.sol";

contract GovernanceLifecycleDemo is Script {
    function run() external {
        // Read deployment JSON
        string memory path = "deployments/local.json";
        string memory json = vm.readFile(path);

        address governorAddr = vm.parseJsonAddress(json, ".GameGovernor");
        address itemAddr = vm.parseJsonAddress(json, ".GameItem");
        address timelockAddr = vm.parseJsonAddress(json, ".GameTimelock");
        address tokenAddr = vm.parseJsonAddress(json, ".GameToken");

        // Use the funded local Anvil private key #0
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=== STARTING DAO GOVERNANCE LIFECYCLE DEMO ===");
        console.log("Deployer Wallet:", deployer);
        console.log("Governor Contract:", governorAddr);
        console.log("Timelock Contract:", timelockAddr);

        GameToken token = GameToken(tokenAddr);
        GameItem item = GameItem(itemAddr);
        GameGovernor gov = GameGovernor(payable(governorAddr));

        // 1. Mint tokens to self and delegate voting power to self
        console.log("\n[Step 1] Minting tokens to self and delegating voting power...");
        vm.prank(deployer);
        token.mint(deployer, 100_000 * 10 ** 18);
        vm.prank(deployer);
        token.delegate(deployer);
        console.log("SUCCESS: Tokens minted and delegated. Current Votes:", token.getVotes(deployer));

        // Let's declare state variables that we will reuse across scoped blocks to avoid stack depth issues
        uint256 proposalId;
        string memory newUri = "ipfs://QmDAOApprovedNewMetadataURI";
        bytes32 descriptionHash = keccak256(bytes("DAO Proposal #1: Update Item 1 Metadata URI"));

        // 2 & 3. Propose update
        {
            console.log("\n[Step 2] Formulating proposal to update metadata...");
            address[] memory targets = new address[](1);
            uint256[] memory values = new uint256[](1);
            bytes[] memory calldatas = new bytes[](1);

            targets[0] = itemAddr;
            values[0] = 0;
            calldatas[0] = abi.encodeWithSelector(GameItem.setItemUri.selector, 1, newUri);

            string memory description = "DAO Proposal #1: Update Item 1 Metadata URI";

            console.log("\n[Step 3] Submitting proposal to Governor...");
            vm.prank(deployer);
            proposalId = gov.propose(targets, values, calldatas, description);
            console.log("SUCCESS: Proposal submitted! Proposal ID:", proposalId);
        }

        // 4. Warp past voting delay
        {
            console.log("\n[Step 4] Warping past voting delay...");
            uint256 delay = gov.votingDelay();
            console.log("Voting Delay (blocks):", delay);
            vm.warp(block.timestamp + delay * 12 + 1); // approximate block time
            vm.roll(block.number + delay + 1);
            console.log("Proposal State (1 = Active):", uint256(gov.state(proposalId)));
        }

        // 5. Cast vote FOR the proposal
        console.log("\n[Step 5] Casting 'FOR' vote...");
        vm.prank(deployer);
        gov.castVote(proposalId, 1); // 1 = For
        console.log("SUCCESS: Vote cast successfully.");

        // 6. Warp past voting period
        {
            console.log("\n[Step 6] Warping past voting period...");
            uint256 period = gov.votingPeriod();
            console.log("Voting Period (blocks):", period);
            vm.warp(block.timestamp + period * 12 + 1); // approximate block time
            vm.roll(block.number + period + 1);
            console.log("Proposal State (4 = Succeeded):", uint256(gov.state(proposalId)));
        }

        // 7. Queue proposal in the Timelock
        {
            console.log("\n[Step 7] Queueing proposal in Timelock...");
            address[] memory targets = new address[](1);
            uint256[] memory values = new uint256[](1);
            bytes[] memory calldatas = new bytes[](1);

            targets[0] = itemAddr;
            values[0] = 0;
            calldatas[0] = abi.encodeWithSelector(GameItem.setItemUri.selector, 1, newUri);

            vm.prank(deployer);
            gov.queue(targets, values, calldatas, descriptionHash);
            console.log("Proposal State (5 = Queued):", uint256(gov.state(proposalId)));
        }

        // 8. Warp past timelock safety window (2 days = 172800 seconds)
        console.log("\n[Step 8] Warping past Timelock enforcement delay...");
        vm.warp(block.timestamp + 2 days + 1);
        vm.roll(block.number + 1);

        // 9. Execute proposal
        {
            console.log("\n[Step 9] Executing DAO Proposal...");
            address[] memory targets = new address[](1);
            uint256[] memory values = new uint256[](1);
            bytes[] memory calldatas = new bytes[](1);

            targets[0] = itemAddr;
            values[0] = 0;
            calldatas[0] = abi.encodeWithSelector(GameItem.setItemUri.selector, 1, newUri);

            vm.prank(deployer);
            gov.execute(targets, values, calldatas, descriptionHash);
            console.log("Proposal State (7 = Executed):", uint256(gov.state(proposalId)));
        }

        // 10. Verify state change
        console.log("\n[Step 10] Verifying protocol state change...");
        string memory currentUri = item.uri(1);
        console.log("Expected URI:", newUri);
        console.log("Actual URI:  ", currentUri);

        require(keccak256(bytes(currentUri)) == keccak256(bytes(newUri)), "FAIL: State change failed!");

        console.log("\n=======================================================");
        console.log("DAO GOVERNANCE LIFECYCLE DEMO SUCCESSFULLY COMPLETED!");
        console.log("The entire lifecycle has run end-to-end flawlessly.");
        console.log("=======================================================");
    }
}
