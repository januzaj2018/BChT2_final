# Internal Security Audit Report — GameFi Protocol

**Project:** GameFi Economy Capstone  
**Auditor:** Aibek (Automated & Manual Review)  
**Date:** May 18, 2026  
**Status:** All Critical/High Issues Mitigated

---

## 1. Executive Summary

The GameFi Protocol is a suite of smart contracts providing an ERC-1155 item economy, an AMM for resource trading, and a yield-bearing rental vault. This audit focused on arithmetic safety, access control, and reentrancy protection.

## 2. Findings & Mitigations

### 2.1 [CRITICAL] RentalVault Yield Recursion
- **Issue:** The original yield calculation was based on `totalAssets()`. However, `totalAssets()` itself included the virtual yield. This created a recursive loop where minting tokens to the vault increased the yield exponentially, making redemptions impossible due to `ERC20InsufficientBalance`.
- **Mitigation:** Refactored `RentalVault.sol` to base yield on `totalSupply()` (shares). Since shares only increase during deposits, the yield debt remains deterministic and manageable. Actual tokens are now minted during a `syncYield()` call within every asset-changing operation.

### 2.2 [HIGH] PriceFeed Heartbeat Check Underflow
- **Issue:** The check `updatedAt >= block.timestamp - HEARTBEAT` could underflow if `block.timestamp` was less than `HEARTBEAT` (e.g., in early local tests or forge forks).
- **Mitigation:** Changed to a safe comparison: `block.timestamp <= updatedAt + HEARTBEAT`.

### 2.3 [MEDIUM] Reentrancy in RentalVault
- **Issue:** `depositNFT` and `withdrawNFT` performed state changes after external calls (implicit in ERC-4626 inheritance).
- **Mitigation:** Added `nonReentrant` modifier to all core functions and strictly followed the Checks-Effects-Interactions (CEI) pattern.

### 2.4 [LOW] Access Control for Minting
- **Issue:** Multiple contracts needed `MINTER_ROLE` on `GameToken` and `GameItem`.
- **Mitigation:** Implemented a granular `AccessControl` system. The `Timelock` (DAO) is the supreme admin and can grant/revoke roles as the protocol evolves.

## 3. Tooling Used
- **Foundry (Forge):** 91 unit, fuzz, and invariant tests.
- **Slither:** Static analysis for common vulnerabilities.
- **Manual Review:** Logic verification for AMM and Governance.

## 4. Conclusion
The protocol logic is robust. The invariant tests confirm that the `k-product` of the AMM never decreases and the `RentalVault` balance remains solvent after the yield refactor.
