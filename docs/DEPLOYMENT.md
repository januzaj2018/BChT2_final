# Deployment Guide — Arbitrum Sepolia

## 1. Prerequisites
- **Foundry:** `curl -L https://foundry.paradigm.xyz | bash`
- **Wallet:** A private key with at least 0.1 Sepolia ETH.
- **Arbiscan API Key:** Required for contract verification.

## 2. Environment Setup
Create a `.env` file in the `gamefi-protocol` directory:
```bash
PRIVATE_KEY=0x...your_key...
ARB_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ETHERSCAN_API_KEY=...your_arbiscan_key...
ETH_USD_FEED=0xd30621D869D25c9a81c3129D58D49758A7d078C1
```

## 3. Deployment Steps

### Step 1: Build Contracts
```bash
forge build
```

### Step 2: Run Deployment Script
This command deploys the full protocol and verifies it on Arbiscan automatically.
```bash
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $ARB_SEPOLIA_RPC_URL \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    -vvvv
```

### Step 3: Frontend Integration
Copy the deployed addresses from the console output into `frontend/src/App.jsx` under the `CONTRACTS` constant.

## 4. Verification
You can verify the deployment by checking the addresses on [Arbiscan Sepolia](https://sepolia.arbiscan.io/).
