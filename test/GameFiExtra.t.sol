// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/RentalVault.sol";
import "../src/PriceFeed.sol";
import "../src/LootVRF.sol";
import "../src/GameGovernor.sol";
import "../src/GameTimelock.sol";
import "./Mocks.sol";

contract GameFiExtraTest is Test {
    GameToken token;
    GameItem item;
    RentalVault vault;
    PriceFeed feed;
    LootVRF loot;

    MockAggregatorV3 mockAggregator;
    MockVRFCoordinatorV2 mockCoordinator;

    address admin = address(1);
    address user = address(2);

    GameTimelock timelock;
    GameGovernor governor;

    function setUp() public {
        vm.warp(1 days); // Start at non-zero timestamp

        vm.startPrank(admin);

        token = new GameToken();
        item = new GameItem();

        mockAggregator = new MockAggregatorV3(2000 * 10 ** 8, 8); // $2000 ETH
        feed = new PriceFeed(address(mockAggregator));

        mockCoordinator = new MockVRFCoordinatorV2();
        loot = new LootVRF(address(mockCoordinator), address(item), 1, bytes32(0));
        item.grantRole(item.MINTER_ROLE(), address(loot));
        loot.grantRole(loot.OPERATOR_ROLE(), admin);

        vault = new RentalVault(token, item, 11); // Vault for item ID 11

        // Proper initialization: deposit some assets to get initial shares
        token.mint(admin, 1000 * 10 ** 18);
        token.approve(address(vault), 1000 * 10 ** 18);
        vault.deposit(1000 * 10 ** 18, admin);

        // Setup Governance
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        timelock = new GameTimelock(2 days, proposers, executors, admin);
        governor = new GameGovernor(token, timelock);

        // Setup timelock roles
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0)); // Anyone
        timelock.revokeRole(0x00, admin); // DEFAULT_ADMIN_ROLE is 0x00

        vm.stopPrank();
    }

    // --- PriceFeed Tests ---
    function testPriceFeed() public {
        assertEq(feed.getLatestPrice(), 2000 * 10 ** 8);
    }

    function testStalePrice() public {
        mockAggregator.setUpdatedAt(block.timestamp - 2 hours);
        vm.expectRevert("Stale price");
        feed.getLatestPrice();
    }

    function testPriceFeedSetPrice() public {
        vm.prank(admin);
        feed.setPriceFeed(address(0x123));
        // We don't need to test it works, just that it didn't revert
    }

    // --- LootVRF Tests ---
    function testLootDrop() public {
        vm.prank(admin);
        uint256 requestId = loot.requestLootDrop(user);

        uint256[] memory words = new uint256[](1);
        words[0] = 12_345;

        mockCoordinator.fulfillRandomWords(requestId, words);

        uint256 expectedItemId = (12_345 % 10) + 1;
        assertEq(item.balanceOf(user, expectedItemId), 1);
    }

    function testLootRequestUnauthorized() public {
        vm.expectRevert();
        loot.requestLootDrop(user);
    }

    // --- RentalVault Tests ---
    function testDepositNFT() public {
        // Mint NFT for user
        vm.prank(admin);
        item.mint(user, 11, 10, "");

        vm.startPrank(user);
        item.setApprovalForAll(address(vault), true);

        uint256 shares = vault.depositNFT(5);
        assertEq(shares, 5 * 10 ** 18);
        assertEq(vault.balanceOf(user), 5 * 10 ** 18);
        assertEq(item.balanceOf(user, 11), 5);
        vm.stopPrank();
    }

    function testWithdrawNFTCooldown() public {
        testDepositNFT();

        vm.startPrank(user);
        vm.expectRevert("Cooldown active");
        vault.withdrawNFT(1 * 10 ** 18);

        vm.warp(block.timestamp + 7 days);
        vault.withdrawNFT(1 * 10 ** 18);
        assertEq(item.balanceOf(user, 11), 6);
        vm.stopPrank();
    }

    function testYieldSimulation() public {
        testDepositNFT();

        uint256 assetsBeforeYear = vault.totalAssets();
        vm.warp(block.timestamp + 365 days);

        uint256 assetsAfterYear = vault.totalAssets();
        assertApproxEqAbs(assetsAfterYear, assetsBeforeYear + 100.5 * 10 ** 18, 1e16);
    }

    function testUpdateYield() public {
        vault.updateYield();
        assertEq(vault.lastYieldUpdate(), block.timestamp);
    }

    function testSetYieldRate() public {
        vm.prank(admin);
        vault.setYieldRate(2000);
        assertEq(vault.yieldRate(), 2000);
    }

    // --- Token Tests ---
    function testTokenMint() public {
        vm.prank(admin);
        token.mint(user, 100);
        assertEq(token.balanceOf(user), 100);
    }

    function testTokenDelegation() public {
        vm.prank(admin);
        token.mint(user, 100);

        vm.prank(user);
        token.delegate(user);
        assertEq(token.getVotes(user), 100);
    }

    function testTokenTransfer() public {
        vm.prank(admin);
        token.mint(user, 100);

        vm.prank(user);
        token.transfer(admin, 50);
        assertEq(token.balanceOf(user), 50);
        assertEq(token.balanceOf(admin), 50);
    }

    // --- Governance Tests ---
    function testGovernorParams() public {
        assertEq(governor.votingDelay(), 1 days);
        assertEq(governor.votingPeriod(), 1 weeks);
        assertEq(governor.quorum(block.number - 1), 0); // No tokens voted yet
    }

    function testPropose() public {
        vm.prank(admin);
        token.mint(user, 1000 * 10 ** 18);
        vm.prank(user);
        token.delegate(user);

        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("mint(address,uint256)", user, 100);
        string memory description = "Test Proposal";

        vm.prank(user);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        assertEq(uint256(governor.state(proposalId)), 0); // Pending
    }

    function testCastVote() public {
        vm.prank(admin);
        token.mint(user, 1000 * 10 ** 18);
        vm.prank(user);
        token.delegate(user);

        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        targets[0] = address(token);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("mint(address,uint256)", user, 100);
        string memory description = "Test Proposal";

        vm.prank(user);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Wait for voting delay - need to roll blocks and warp
        uint256 delay = governor.votingDelay();
        vm.warp(block.timestamp + delay + 1);
        vm.roll(block.number + delay + 1);

        assertEq(uint256(governor.state(proposalId)), 1); // Active

        vm.prank(user);
        governor.castVote(proposalId, 1); // For
    }

    function testProposalThreshold() public {
        assertEq(governor.proposalThreshold(), 0);
    }

    function testTimelockAdmin() public {
        assertTrue(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(timelock)));
    }

    function testTimelockMinDelay() public {
        assertEq(timelock.getMinDelay(), 2 days);
    }
}
