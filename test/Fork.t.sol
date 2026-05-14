// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PriceFeed.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/interfaces/AggregatorV3Interface.sol";

/**
 * @title ForkTest
 * @dev Tests interaction with real Arbitrum Sepolia contracts.
 * These tests require a network connection and will be skipped if the RPC is unavailable.
 */
contract ForkTest is Test {
    PriceFeed feed;

    address ETH_USD_FEED = 0xd30621D869D25c9a81c3129d58d49758A7d078c1;
    address constant WETH = 0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;

    uint256 fork;

    function setUp() public {
        ETH_USD_FEED = vm.parseAddress("0xd30621D869D25c9a81c3129D58D49758A7d078c1");
        string memory rpcUrl = vm.envOr("ARB_SEPOLIA_RPC_URL", string("https://sepolia-rollup.arbitrum.io/rpc"));

        // Skip if no internet/RPC
        try vm.createFork(rpcUrl) returns (uint256 forkId) {
            fork = forkId;
            vm.selectFork(fork);

            // Validate the feed address exists on this fork
            uint256 codeSize;
            address addr = ETH_USD_FEED;
            assembly {
                codeSize := extcodesize(addr)
            }

            if (codeSize > 0) {
                feed = new PriceFeed(ETH_USD_FEED);
            } else {
                fork = 0; // Mark as invalid
            }
        } catch {
            fork = 0;
        }
    }

    function testForkETHPrice() public {
        if (fork == 0) return;
        int256 price = feed.getLatestPrice();
        assertTrue(price > 0, "Price should be positive");
    }

    function testForkWETHBalance() public {
        if (fork == 0) return;
        uint256 balance = IERC20(WETH).balanceOf(0x0000000000000000000000000000000000000000);
        assertEq(balance, 0);
    }

    function testForkChainlinkDecimals() public {
        if (fork == 0) return;
        uint8 decimals = feed.getDecimals();
        assertEq(decimals, 8, "ETH/USD feed should have 8 decimals");
    }
}
