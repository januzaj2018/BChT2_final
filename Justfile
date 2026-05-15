# GameFi Protocol Commands
set dotenv-load := true

# Default variables

ANVIL_KEY := "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
RPC_URL := "http://localhost:8545"

# Contract addresses — update these after each fresh deploy

GAME_TOKEN := "0x5FbDB2315678afecb367f032d93F642f64180aa3"
GAME_ITEM := "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

# List all available commands
default:
    @just --list

# ---- SETUP & DEVELOPMENT ----

# Install both Foundry and Frontend dependencies
install:
    forge install
    cd frontend && npm install

# Start the local Anvil test node
node:
    anvil

# Deploy all smart contracts to the local Anvil node
deploy:
    forge script script/Deploy.s.sol --rpc-url {{ RPC_URL }} --private-key {{ ANVIL_KEY }} --broadcast

# Run post-deployment decentralized checks
verify-deploy:
    forge script script/VerifyDeployment.s.sol --rpc-url {{ RPC_URL }} --sig "run()"

# Run the end-to-end DAO governance lifecycle (propose, vote, queue, execute)
governance-demo:
    forge script script/GovernanceLifecycleDemo.s.sol --rpc-url {{ RPC_URL }} --sig "run()"

# Deploy all smart contracts to Arbitrum Sepolia L2 (uses PRIVATE_KEY from environment)
deploy-l2:
    @if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" ]; then \
        echo "ERROR: Please update the PRIVATE_KEY in your .env file with your funded L2 private key."; \
        exit 1; \
    fi
    forge script script/Deploy.s.sol --rpc-url https://sepolia-rollup.arbitrum.io/rpc --broadcast

# Read deployments/local.json (written by Deploy.s.sol) and patch:
#   - frontend/src/contracts.local.json  (used by App.jsx import)
#   - Justfile GAME_TOKEN and GAME_ITEM variables (used by cast commands)

# Requires: jq  (brew install jq / apt install jq)
sync-addresses:
    #!/usr/bin/env bash
    set -e
    JSON="./deployments/local.json"
    if [ ! -f "$JSON" ]; then
        echo "ERROR: $JSON not found. Run 'just deploy' first."
        exit 1
    fi
    echo "Reading from $JSON..."

    GAME_TOKEN=$(jq -r '.GameToken' "$JSON")
    GAME_ITEM=$(jq -r '.GameItem' "$JSON")
    PRICE_FEED=$(jq -r '.PriceFeed' "$JSON")
    GAME_AMM=$(jq -r '.GameAMM' "$JSON")
    RENTAL_VAULT=$(jq -r '.RentalVault' "$JSON")
    GAME_TIMELOCK=$(jq -r '.GameTimelock' "$JSON")
    GAME_GOVERNOR=$(jq -r '.GameGovernor' "$JSON")
    LOOT_VRF=$(jq -r '.LootVRF' "$JSON")

    echo "Syncing frontend/src/contracts.local.json..."
    cat > frontend/src/contracts.local.json << EOF
    {
      "GameToken":    "$GAME_TOKEN",
      "GameItem":     "$GAME_ITEM",
      "PriceFeed":    "$PRICE_FEED",
      "GameAMM":      "$GAME_AMM",
      "RentalVault":  "$RENTAL_VAULT",
      "GameTimelock": "$GAME_TIMELOCK",
      "GameGovernor": "$GAME_GOVERNOR",
      "LootVRF":      "$LOOT_VRF"
    }
    EOF

    echo "Patching Justfile GAME_TOKEN and GAME_ITEM..."
    sed -i "s|^GAME_TOKEN :=.*|GAME_TOKEN := \"$GAME_TOKEN\"|" Justfile
    sed -i "s|^GAME_ITEM  :=.*|GAME_ITEM  := \"$GAME_ITEM\"|" Justfile

    echo ""
    echo "Done! Addresses synced:"
    echo "  GameToken:    $GAME_TOKEN"
    echo "  GameItem:     $GAME_ITEM"
    echo "  GameAMM:      $GAME_AMM"
    echo "  RentalVault:  $RENTAL_VAULT"
    echo "  GameGovernor: $GAME_GOVERNOR"
    echo ""
    echo "Restart the Vite dev server to pick up the new contracts.local.json."

# One-shot: deploy contracts AND sync all addresses automatically
deploy-sync: deploy sync-addresses

# Start the Frontend Vite development server
dev:
    cd frontend && npm run dev

# ---- TESTING & FORMATTING ----

# Run the smart contract test suite
test:
    forge test

# Check test coverage
coverage:
    forge coverage

# Format all Solidity code
format:
    forge fmt

# ---- WALLET FUNDING (LOCAL NODE) ----
# Send 10 ETH to a specified address for gas fees

# Usage: just fund-eth 0xYourAddress
fund-eth address:
    cast send {{ address }} --value 10ether --rpc-url {{ RPC_URL }} --private-key {{ ANVIL_KEY }}
    @echo "Sent 10 ETH to {{ address }}"

# Mint GAME tokens to a specified address (default: 1000 tokens)
# Usage: just mint-game 0xYourAddress

# Usage: just mint-game 0xYourAddress 500
mint-game address amount="1000":
    #!/usr/bin/env bash
    AMOUNT_WEI=$(cast to-wei {{ amount }})
    cast send {{ GAME_TOKEN }} "mint(address,uint256)" {{ address }} $AMOUNT_WEI \
        --rpc-url {{ RPC_URL }} --private-key {{ ANVIL_KEY }}
    @echo "Minted {{ amount }} GAME tokens to {{ address }}"

# ---- ITEM MANAGEMENT (LOCAL NODE) ----
# Burn ALL 10 resource item types from an address back to zero.
# Useful when an account has millions of items causing UI freezes.

# Usage: just burn-all-items 0xYourAddress
burn-all-items address:
    #!/usr/bin/env bash
    set -e
    echo "Reading current balances for {{ address }}..."
    BALANCES=$(cast call {{ GAME_ITEM }} \
        "balanceOfBatch(address[],uint256[])" \
        "[{{ address }},{{ address }},{{ address }},{{ address }},{{ address }},{{ address }},{{ address }},{{ address }},{{ address }},{{ address }}]" \
        "[1,2,3,4,5,6,7,8,9,10]" \
        --rpc-url {{ RPC_URL }})
    echo "Current balances (raw): $BALANCES"
    echo "Burning all 10 item types..."
    cast send {{ GAME_ITEM }} \
        "burnBatch(address,uint256[],uint256[])" \
        "{{ address }}" \
        "[1,2,3,4,5,6,7,8,9,10]" \
        "[999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000,999999000000000000000000]" \
        --rpc-url {{ RPC_URL }} --private-key {{ ANVIL_KEY }}
    @echo "Items burned for {{ address }}"

# Give an address a reasonable amount of each item (100 of each, 18 decimals)

# Usage: just give-items 0xYourAddress
give-items address:
    cast send {{ GAME_ITEM }} \
        "mintBatch(address,uint256[],uint256[],bytes)" \
        "{{ address }}" \
        "[1,2,3,4,5,6,7,8,9,10]" \
        "[100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000,100000000000000000000]" \
        "0x" \
        --rpc-url {{ RPC_URL }} --private-key {{ ANVIL_KEY }}
    @echo "Gave 100 of each item to {{ address }}"

# Nuclear option: restart everything from scratch

# Stop anvil, redeploy, and re-fund. Run anvil in a separate terminal first.
reset: deploy
    @echo "Redeployed all contracts with fresh state."
    @echo "Update GAME_TOKEN and GAME_ITEM addresses in this Justfile, then run:"
    @echo "  just fund-eth <YOUR_ADDRESS>"
    @echo "  just mint-game <YOUR_ADDRESS>"
    @echo "  just give-items <YOUR_ADDRESS>"
