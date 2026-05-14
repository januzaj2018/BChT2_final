// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PriceFeed.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../src/interfaces/AggregatorV3Interface.sol";

contract ForkTest is Test {
    PriceFeed feed;
    
    // Arbitrum Sepolia Addresses
    address constant ETH_USD_FEED = 0xd30621D869D25c9a81c3129d58d49758A7d078c1;
    address constant WETH = 0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;

    uint256 fork;

    function setUp() public {
        string memory rpcUrl = vm.envOr("ARB_SEPOLIA_RPC_URL", string("https://sepolia-rollup.arbitrum.io/rpc"));
        
        try vm.createFork(rpcUrl) returns (uint256 forkId) {
            fork = forkId;
            vm.selectFork(fork);
            
            feed = new PriceFeed(ETH_USD_FEED);

            // Warp to make sure price is not stale
            try AggregatorV3Interface(ETH_USD_FEED).latestRoundData() returns (uint80, int256, uint256, uint256 updatedAt, uint80) {
                vm.warp(updatedAt + 1);
            } catch {}
        } catch {
            console.log("Fork creation failed. Skipping fork tests.");
        }
    }

    function testForkETHPrice() public {
        if (fork == 0 && block.chainid != 421614) return;
        int256 price = feed.getLatestPrice();
        assertTrue(price > 0, "Price should be positive");
        console.log("ETH Price on Fork:", uint256(price));
    }

    function testForkWETHBalance() public {
        if (fork == 0 && block.chainid != 421614) return;
        uint256 balance = IERC20(WETH).balanceOf(0x0000000000000000000000000000000000000000); 
        assertEq(balance, 0);
    }

    function testForkChainlinkDecimals() public {
        if (fork == 0 && block.chainid != 421614) return;
        uint8 decimals = feed.getDecimals();
        assertEq(decimals, 8, "ETH/USD feed should have 8 decimals");
    }
}
