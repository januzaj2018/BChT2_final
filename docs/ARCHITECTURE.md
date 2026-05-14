# System Architecture — GameFi Protocol

## 1. Overview
The GameFi Protocol is a decentralized economy for in-game assets. It leverages Arbitrum's L2 speed to provide low-cost trading, staking, and governance.

## 2. Core Components

### 2.1 Asset Layer
- **GameToken (ERC-20):** The primary currency of the ecosystem. Supports `ERC20Votes` for DAO participation.
- **GameItem (ERC-1155):** A multi-token standard representing resources (Wood, Stone) and rare items (Swords, Armor). Includes a custom `craftItem` logic driven by on-chain recipes.
- **GameItemFactory:** Deploys new item collections using `CREATE2` for deterministic addressing.

### 2.2 Marketplace Layer
- **GameAMM:** A constant-product AMM (`x * y = k`) allowing users to swap between GameToken and items.
- **LootVRF:** Uses Chainlink VRF V2 to provide provably fair item drops for users stake-depositing in the vault.

### 2.3 Financial Layer
- **RentalVault (ERC-4626):** A yield-bearing vault where users stake GameTokens and NFTs. Stakeholders earn passive yield in GameTokens and have a chance at Loot VRF drops.

### 2.4 Governance Layer
- **GameGovernor:** An OpenZeppelin-based governor contract.
- **GameTimelock:** A 2-day delay mechanism for all administrative actions, ensuring user security against "flash governance" attacks.

## 3. Technical Design Choices

### 3.1 Yield Distribution
The `RentalVault` uses a "sync-on-interaction" pattern. Instead of expensive loops, yield is calculated and minted only when a user deposits or withdraws, significantly reducing gas costs.

### 3.2 Invariant Enforcement
The AMM strictly enforces the `k-invariant`. Our test suite includes formal invariant tests that perform 3000+ random swaps to verify that `k` never decreases.

## 4. Trust Assumptions
- **Chainlink VRF:** Assumed to provide unbiased randomness.
- **Chainlink Price Feeds:** Assumed to provide accurate market prices for ETH/GAME valuation.
- **DAO Members:** Assumed that 51% of voting power will act in the protocol's interest.
