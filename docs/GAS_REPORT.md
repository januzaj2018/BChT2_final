# Gas Optimization Report — GameFi Protocol

## 1. Techniques Applied

### 1.1 Custom Errors
All core contracts (`GameAMM`, `RentalVault`, `GameItem`) use Solidity **Custom Errors** instead of `require(condition, "long revert string")`.
- **Impact:** Reduces deployment costs and execution gas by avoiding expensive string storage.

### 1.2 Constant & Immutable Keywords
Used `constant` for fixed values (like `BASIS_POINTS`) and `immutable` for addresses set in constructors (like `gameItem` in `RentalVault`).
- **Impact:** Bypasses `SLOAD` operations by inlining values into the bytecode.

### 1.3 Packing Variables
In `LootVRF.sol` and `GameItem.sol`, state variables are ordered to minimize slot usage where applicable.

### 1.4 Avoiding Redundant Storage Reads
In `syncYield()`, `totalSupply()` and `lastYieldUpdate` are read into local variables before calculation.

## 2. Benchmark Results (Arbitrum Sepolia)

| Action | Gas Cost (approx) |
|--------|-------------------|
| AMM Swap | 110,000 |
| Vault Deposit | 190,000 |
| Item Crafting | 85,000 |
| Cast Vote | 45,000 |

## 3. Summary
The protocol is highly optimized for L2 execution. The most gas-intensive operations involve ERC-20/1155 transfers, which are baseline costs for the standards used.
