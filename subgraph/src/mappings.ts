import { BigInt, Bytes } from "@graphprotocol/graph-ts"
import {
  ItemMinted,
  ItemCrafted
} from "../generated/GameItem/GameItem"
import {
  LiquidityAdded,
  LiquidityRemoved,
  Swap as SwapEvent
} from "../generated/GameAMM/GameAMM"
import {
  NFTDeposited
} from "../generated/RentalVault/RentalVault"
import {
  ProposalCreated,
  VoteCast
} from "../generated/GameGovernor/GameGovernor"
import {
  GameItem,
  Craft,
  AMMLiquidity,
  Swap,
  VaultDeposit,
  Proposal,
  Vote
} from "../generated/schema"

export function handleItemMinted(event: ItemMinted): void {
  let id = event.params.tokenId.toString() + "-" + event.params.to.toHexString()
  let entity = GameItem.load(id)
  if (!entity) {
    entity = new GameItem(id)
    entity.tokenId = event.params.tokenId
    entity.owner = event.params.to
    entity.balance = BigInt.fromI32(0)
  }
  entity.balance = entity.balance.plus(event.params.amount)
  entity.save()
}

export function handleItemCrafted(event: ItemCrafted): void {
  let entity = new Craft(event.transaction.hash.toHex() + "-" + event.logIndex.toString())
  entity.user = event.params.user
  entity.recipeId = event.params.recipeId
  entity.inputs = event.params.inputIds
  entity.outputs = event.params.outputId
  entity.save()
}

export function handleLiquidityAdded(event: LiquidityAdded): void {
  let id = event.params.provider.toHex()
  let entity = AMMLiquidity.load(id)
  if (!entity) {
    entity = new AMMLiquidity(id)
    entity.user = event.params.provider
    entity.lpAmount = BigInt.fromI32(0)
    entity.reserveX = BigInt.fromI32(0)
    entity.reserveY = BigInt.fromI32(0)
  }
  entity.lpAmount = entity.lpAmount.plus(event.params.lpTokens)
  entity.save()
}

export function handleLiquidityRemoved(event: LiquidityRemoved): void {
  let id = event.params.provider.toHex()
  let entity = AMMLiquidity.load(id)
  if (entity) {
    entity.lpAmount = entity.lpAmount.minus(event.params.lpTokens)
    entity.save()
  }
}

export function handleSwap(event: SwapEvent): void {
  let entity = new Swap(event.transaction.hash.toHex() + "-" + event.logIndex.toString())
  entity.user = event.params.user
  entity.tokenIn = event.params.tokenIn
  entity.amountIn = event.params.amountIn
  entity.tokenOut = Bytes.empty() // Simplified
  entity.amountOut = event.params.amountOut
  entity.timestamp = event.block.timestamp
  entity.save()
}

export function handleNFTDeposited(event: NFTDeposited): void {
  let entity = new VaultDeposit(event.transaction.hash.toHex() + "-" + event.logIndex.toString())
  entity.user = event.params.user
  entity.tokenId = event.params.tokenId
  entity.amount = event.params.amount
  entity.shares = event.params.shares
  entity.timestamp = event.block.timestamp
  entity.save()
}

export function handleProposalCreated(event: ProposalCreated): void {
  let entity = new Proposal(event.params.proposalId.toString())
  entity.proposer = event.params.proposer
  entity.targets = changetype<Bytes[]>(event.params.targets)
  entity.values = event.params.values
  entity.signatures = event.params.signatures
  entity.calldatas = event.params.calldatas
  entity.startBlock = event.params.voteStart
  entity.endBlock = event.params.voteEnd
  entity.description = event.params.description
  entity.status = "Pending"
  entity.save()
}

export function handleVoteCast(event: VoteCast): void {
  let entity = new Vote(event.transaction.hash.toHex() + "-" + event.logIndex.toString())
  entity.voter = event.params.voter
  entity.proposalId = event.params.proposalId
  entity.support = event.params.support
  entity.weight = event.params.weight
  entity.reason = event.params.reason
  entity.save()
}
