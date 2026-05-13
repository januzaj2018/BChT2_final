// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/RentalVault.sol";
import "../src/PriceFeed.sol";
import "../src/LootVRF.sol";
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

    function setUp() public {
        vm.warp(1 days); // Start at non-zero timestamp

        vm.startPrank(admin);

        token = new GameToken();
        item = new GameItem();

        mockAggregator = new MockAggregatorV3(2000 * 10**8, 8); // $2000 ETH
        feed = new PriceFeed(address(mockAggregator));

        mockCoordinator = new MockVRFCoordinatorV2();
        loot = new LootVRF(address(mockCoordinator), address(item), 1, bytes32(0));
        item.grantRole(item.MINTER_ROLE(), address(loot));
        loot.grantRole(loot.OPERATOR_ROLE(), admin);

        vault = new RentalVault(token, item, 11); // Vault for item ID 11
        
        // Proper initialization: deposit some assets to get initial shares
        token.mint(admin, 1000 * 10**18);
        token.approve(address(vault), 1000 * 10**18);
        vault.deposit(1000 * 10**18, admin);

        vm.stopPrank();
    }

    // --- PriceFeed Tests ---
    function testPriceFeed() public {
        assertEq(feed.getLatestPrice(), 2000 * 10**8);
    }

    function testStalePrice() public {
        mockAggregator.setUpdatedAt(block.timestamp - 2 hours);
        vm.expectRevert("Stale price");
        feed.getLatestPrice();
    }

    // --- LootVRF Tests ---
    function testLootDrop() public {
        vm.prank(admin);
        uint256 requestId = loot.requestLootDrop(user);

        uint256[] memory words = new uint256[](1);
        words[0] = 12345;
        
        mockCoordinator.fulfillRandomWords(requestId, words);

        uint256 expectedItemId = (12345 % 10) + 1;
        assertEq(item.balanceOf(user, expectedItemId), 1);
    }

    // --- RentalVault Tests ---
    function testDepositNFT() public {
        // Mint NFT for user
        vm.prank(admin);
        item.mint(user, 11, 10, "");

        vm.startPrank(user);
        item.setApprovalForAll(address(vault), true);
        
        uint256 shares = vault.depositNFT(5);
        // Initial state: 1000 assets, 1000 shares.
        // depositNFT(5) -> virtualAssets = 5e18.
        // Shares should be 5e18 (1:1 ratio)
        assertEq(shares, 5 * 10**18);
        assertEq(vault.balanceOf(user), 5 * 10**18);
        assertEq(item.balanceOf(user, 11), 5);
        vm.stopPrank();
    }

    function testWithdrawNFTCooldown() public {
        testDepositNFT();

        vm.startPrank(user);
        vm.expectRevert("Cooldown active");
        vault.withdrawNFT(1 * 10**18);

        vm.warp(block.timestamp + 7 days);
        vault.withdrawNFT(1 * 10**18);
        assertEq(item.balanceOf(user, 11), 6);
        vm.stopPrank();
    }

    function testYieldSimulation() public {
        testDepositNFT();

        // After testDepositNFT:
        // totalAssets = 1005e18 (approx, depends on yield since last update)
        // lastYieldUpdate was in setUp or depositNFT.
        
        uint256 assetsBeforeYear = vault.totalAssets();
        vm.warp(block.timestamp + 365 days);
        
        uint256 assetsAfterYear = vault.totalAssets();
        // 10% yield on ~1005e18 = ~100.5e18
        assertApproxEqAbs(assetsAfterYear, assetsBeforeYear + 100.5 * 10**18, 1e16);
    }
}
