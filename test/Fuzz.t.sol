// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "../src/PriceFeed.sol";
import "../src/LootVRF.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./Mocks.sol";

contract FuzzTest is Test, ERC1155Holder {
    GameAMM amm;
    RentalVault vault;
    GameToken token;
    GameItem item;
    PriceFeed feed;
    LootVRF loot;
    MockERC20 tokenX;
    MockERC20 tokenY;

    MockVRFCoordinatorV2 mockCoordinator;
    MockAggregatorV3 mockAggregator;

    address user = address(100);

    function setUp() public {
        tokenX = new MockERC20("X", "X");
        tokenY = new MockERC20("Y", "Y");
        amm = new GameAMM(address(tokenX), address(tokenY));

        token = new GameToken();
        item = new GameItem();
        vault = new RentalVault(token, item, 1); // targetTokenId 1

        mockAggregator = new MockAggregatorV3(2000e8, 8);
        feed = new PriceFeed(address(mockAggregator));

        mockCoordinator = new MockVRFCoordinatorV2();
        loot = new LootVRF(address(mockCoordinator), address(item), 1, bytes32(0));

        tokenX.mint(address(this), 1e30);
        tokenY.mint(address(this), 1e30);
        tokenX.approve(address(amm), type(uint256).max);
        tokenY.approve(address(amm), type(uint256).max);

        // Initial liquidity
        amm.addLiquidity(1e18, 1e18);

        vm.label(user, "User");

        // Grant roles
        token.grantRole(token.MINTER_ROLE(), address(this));
        token.grantRole(token.MINTER_ROLE(), address(vault));
        item.grantRole(item.MINTER_ROLE(), address(this));
    }

    function testFuzzSwap(uint256 amountIn) public {
        amountIn = bound(amountIn, 1000, 1e25);

        tokenX.mint(user, amountIn);
        vm.startPrank(user);
        tokenX.approve(address(amm), amountIn);

        uint256 reserveXBefore = amm.reserveX();
        uint256 reserveYBefore = amm.reserveY();
        uint256 kBefore = reserveXBefore * reserveYBefore;

        uint256 amountOut = amm.swap(address(tokenX), amountIn, 0);

        uint256 reserveXAfter = amm.reserveX();
        uint256 reserveYAfter = amm.reserveY();
        uint256 kAfter = reserveXAfter * reserveYAfter;

        assertTrue(kAfter >= kBefore, "K-invariant decreased");
        assertTrue(amountOut > 0, "Zero amount out");
        vm.stopPrank();
    }

    function testFuzzDeposit(uint256 amount) public {
        amount = bound(amount, 1, 1e25);

        token.mint(user, amount);
        vm.startPrank(user);
        token.approve(address(vault), amount);

        uint256 shares = vault.deposit(amount, user);

        assertEq(vault.balanceOf(user), shares);
        assertTrue(shares > 0);
        vm.stopPrank();
    }

    function testFuzzVoteWeight(uint256 amount) public {
        amount = bound(amount, 1, 1e25);

        token.mint(user, amount);
        vm.startPrank(user);
        token.delegate(user);

        vm.roll(block.number + 1);

        assertEq(token.getVotes(user), amount);
        vm.stopPrank();
    }

    function testFuzzVaultRedeem(uint256 amount) public {
        amount = bound(amount, 1e18, 1e25);
        token.mint(user, amount);
        vm.startPrank(user);
        token.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, user);
        vm.stopPrank();

        vm.warp(block.timestamp + 8 days);

        vm.startPrank(user);
        uint256 assets = vault.redeem(shares, user, user);
        assertTrue(assets >= amount);
        vm.stopPrank();
    }

    function testFuzzAMMGetAmountOut(uint256 amountIn) public {
        amountIn = bound(amountIn, 1, 1e25);
        uint256 out = amm.getAmountOut(amountIn, true);
        if (amountIn > 0 && amm.reserveX() > 0) {
            uint256 amountInWithFee = amountIn * 997;
            uint256 numerator = amountInWithFee * amm.reserveY();
            uint256 denominator = (amm.reserveX() * 1000) + amountInWithFee;
            uint256 expected = numerator / denominator;
            // Allow 1 wei difference for rounding if necessary, but it should match exactly
            assertApproxEqAbs(out, expected, 1);
        }
    }

    function testFuzzGameItemMint(uint256 amount) public {
        amount = bound(amount, 1, 1e18);
        vm.prank(address(this));
        item.mint(user, 1, amount, "");
        assertEq(item.balanceOf(user, 1), amount);
    }

    function testFuzzGameItemBurn(uint256 amount) public {
        amount = bound(amount, 1, 1e18);
        vm.startPrank(address(this));
        item.mint(user, 1, amount, "");
        item.burn(user, 1, amount);
        assertEq(item.balanceOf(user, 1), 0);
        vm.stopPrank();
    }

    function testFuzzPriceFeed(int256 price) public {
        price = bound(price, 1, type(int256).max);
        mockAggregator.setPrice(price);
        assertEq(feed.getLatestPrice(), price);
    }

    function testFuzzRentalVaultSetYieldRate(uint256 rate) public {
        rate = bound(rate, 0, 10_000);
        vm.prank(address(this));
        vault.setYieldRate(rate);
        assertEq(vault.yieldRate(), rate);
    }

    function testFuzzTokenTransfer(uint256 amount) public {
        amount = bound(amount, 1, 1e25);
        token.mint(address(this), amount);
        token.transfer(user, amount);
        assertEq(token.balanceOf(user), amount);
    }

    // Required by ERC1155Holder
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
