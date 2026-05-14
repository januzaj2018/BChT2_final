// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameToken.sol";
import "../src/GameGovernor.sol";
import "../src/GameTimelock.sol";
import "../src/GameItem.sol";

contract GovernanceE2E is Test {
    GameToken token;
    GameGovernor governor;
    GameTimelock timelock;
    GameItem item;

    address deployer = address(1);
    address proposer = address(2);
    address voter1 = address(3);
    address voter2 = address(4);

    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 public constant MIN_DELAY = 2 days;

    function setUp() public {
        vm.startPrank(deployer);

        token = new GameToken();
        item = new GameItem();

        // Setup Timelock
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        timelock = new GameTimelock(MIN_DELAY, proposers, executors, deployer);

        // Setup Governor
        governor = new GameGovernor(token, timelock);

        // Grant Roles
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0)); // Open execution

        // Item admin should be Timelock
        item.grantRole(item.DEFAULT_ADMIN_ROLE(), address(timelock));
        // item.revokeRole(item.DEFAULT_ADMIN_ROLE(), deployer); // For demo, we keep deployer for a bit

        // Distribute tokens for voting power
        token.mint(voter1, 100_000 * 10 ** 18);
        token.mint(voter2, 100_000 * 10 ** 18);

        vm.stopPrank();

        // Delegate voting power
        vm.prank(voter1);
        token.delegate(voter1);
        vm.prank(voter2);
        token.delegate(voter2);

        vm.roll(block.number + 1);
    }

    function testFullGovernanceLifecycle() public {
        // 1. Propose: Change item URI for tokenId 1
        string memory newUri = "ipfs://QmNewMetadata";

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(item);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(GameItem.setItemUri.selector, 1, newUri);

        string memory description = "Proposal #1: Update Item 1 Metadata";

        vm.prank(voter1);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        assertEq(uint256(governor.state(proposalId)), 0); // Pending

        // 2. Wait for Voting Delay
        vm.warp(block.timestamp + governor.votingDelay() + 1);
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(uint256(governor.state(proposalId)), 1); // Active

        // 3. Vote
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // For

        vm.prank(voter2);
        governor.castVote(proposalId, 1); // For

        // 4. Wait for Voting Period
        vm.warp(block.timestamp + governor.votingPeriod() + 1);
        vm.roll(block.number + governor.votingPeriod() + 1);
        assertEq(uint256(governor.state(proposalId)), 4); // Succeeded

        // 5. Queue
        bytes32 descriptionHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descriptionHash);
        assertEq(uint256(governor.state(proposalId)), 5); // Queued

        // 6. Wait for Timelock Delay
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // 7. Execute
        governor.execute(targets, values, calldatas, descriptionHash);
        assertEq(uint256(governor.state(proposalId)), 7); // Executed

        // Verify state change
        assertEq(item.uri(1), newUri);
    }
}
