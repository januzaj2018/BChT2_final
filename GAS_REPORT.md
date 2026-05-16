Ran 1 test for test/GovernanceE2E.t.sol:GovernanceE2E
[PASS] testFullGovernanceLifecycle() (gas: 353740)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 29.61ms (12.42ms CPU time)

Ran 26 tests for test/AdvancedFeatures.t.sol:AdvancedFeaturesTest
[PASS] testAccessControlBlocksUnauthorizedBurn() (gas: 2417174)
[PASS] testAccessControlBlocksUnauthorizedMint() (gas: 2423116)
[PASS] testAccessControlGrantAndRevoke() (gas: 2288547)
[PASS] testFactoryCountIncrementsForBothMethods() (gas: 4670098)
[PASS] testFactoryCreate2IsDeterministic() (gas: 2357489)
[PASS] testFactoryCreate2SameSaltReverts() (gas: 1040502946)
[PASS] testFactoryCreateDeploysNewContract() (gas: 2351509)
[PASS] testFactoryCreateReturnsDifferentAddresses() (gas: 4667080)
[PASS] testFactoryGetDeployedItemOutOfBoundsReverts() (gas: 10697)
[PASS] testProposalThresholdIsOnePercent() (gas: 119927)
[PASS] testProposalThresholdZeroWhenNoSupply() (gas: 11621)
[PASS] testReentrancyAttackBlocked() (gas: 389845)
[PASS] testUUPSStoragePreservedAfterUpgrade() (gas: 135474)
[PASS] testUUPSUpgradeToV2() (gas: 33523)
[PASS] testUUPSUpgradeUnauthorizedReverts() (gas: 21159)
[PASS] testUUPSV1DelegateAndVotes() (gas: 191134)
[PASS] testUUPSV1MintUnauthorizedReverts() (gas: 18553)
[PASS] testUUPSV1MintWorks() (gas: 118596)
[PASS] testUUPSV1NameAndSymbol() (gas: 23251)
[PASS] testUUPSV2BurnWorks() (gas: 144709)
[PASS] testUUPSV2PauseBlocksTransfers() (gas: 194736)
[PASS] testUUPSV2UnpauseResumesTransfers() (gas: 206552)
[PASS] testYulAndSolidityHexProduceSameResult() (gas: 3039303)
[PASS] testYulAssemblyGasBenchmark() (gas: 3043309)
[PASS] testYulHexStringMaxUint() (gas: 3039843)
[PASS] testYulHexStringZero() (gas: 3019946)
Suite result: ok. 26 passed; 0 failed; 0 skipped; finished in 274.73ms (49.05ms CPU time)

Ran 10 tests for test/Fuzz.t.sol:FuzzTest
[PASS] testFuzzAMMGetAmountOut(uint256) (runs: 256, μ: 17078, ~: 16807)
[PASS] testFuzzDeposit(uint256) (runs: 256, μ: 193979, ~: 193708)
[PASS] testFuzzGameItemBurn(uint256) (runs: 256, μ: 41799, ~: 41574)
[PASS] testFuzzGameItemMint(uint256) (runs: 256, μ: 47806, ~: 47495)
[PASS] testFuzzPriceFeed(int256) (runs: 256, μ: 22551, ~: 22338)
[PASS] testFuzzRentalVaultSetYieldRate(uint256) (runs: 256, μ: 20420, ~: 20788)
[PASS] testFuzzSwap(uint256) (runs: 256, μ: 106452, ~: 106573)
[PASS] testFuzzTokenTransfer(uint256) (runs: 256, μ: 117137, ~: 116866)
[PASS] testFuzzVaultRedeem(uint256) (runs: 256, μ: 227218, ~: 227274)
[PASS] testFuzzVoteWeight(uint256) (runs: 256, μ: 183745, ~: 183474)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 271.69ms (998.48ms CPU time)

Ran 31 tests for test/GameFiExtra.t.sol:GameFiExtraTest
[PASS] testAddRecipeEmptyInputsReverts() (gas: 14411)
[PASS] testCastVote() (gas: 243073)
[PASS] testDepositNFT() (gas: 176462)
[PASS] testDepositNFTUnauthorized() (gas: 76627)
[PASS] testGovernorParams() (gas: 23425)
[PASS] testGovernorQueueAndExecute() (gas: 429474)
[PASS] testGovernorVotingDelay() (gas: 7709)
[PASS] testGovernorVotingPeriod() (gas: 7656)
[PASS] testLootDrop() (gas: 140078)
[PASS] testLootRequestUnauthorized() (gas: 13047)
[PASS] testLootVRFGameItemMatches() (gas: 7662)
[PASS] testLootVRFMultipleRequests() (gas: 126998)
[PASS] testLootVRFUnauthorizedFulfill() (gas: 74843)
[PASS] testPriceFeed() (gas: 15432)
[PASS] testPriceFeedSetPrice() (gas: 18924)
[PASS] testProposalThreshold() (gas: 13952)
[PASS] testPropose() (gas: 186636)
[PASS] testRentalVaultAssetMatches() (gas: 7771)
[PASS] testSetYieldRate() (gas: 22045)
[PASS] testStalePrice() (gas: 24145)
[PASS] testTimelockAdmin() (gas: 8742)
[PASS] testTimelockMinDelayValue() (gas: 7729)
[PASS] testTokenDelegation() (gas: 131111)
[PASS] testTokenMint() (gas: 59294)
[PASS] testTokenSymbol() (gas: 12574)
[PASS] testTokenTransfer() (gas: 89604)
[PASS] testUpdateYield() (gas: 8849)
[PASS] testWithdrawNFTCooldown() (gas: 210003)
[PASS] testWithdrawNFTExceedBalance() (gas: 196549)
[PASS] testWithdrawNFTZeroShares() (gas: 17508)
[PASS] testYieldSimulation() (gas: 186401)
Suite result: ok. 31 passed; 0 failed; 0 skipped; finished in 274.71ms (32.26ms CPU time)

Ran 3 tests for test/Fork.t.sol:ForkTest
[PASS] testForkChainlinkDecimals() (gas: 2352)
[PASS] testForkETHPrice() (gas: 2353)
[PASS] testForkWETHBalance() (gas: 2309)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 1.49s (536.63µs CPU time)

Ran 23 tests for test/GameItem.t.sol:GameItemTest
[PASS] testAddRecipeAndCraft() (gas: 315420)
[PASS] testAddRecipeUnauthorized() (gas: 14642)
[PASS] testAddRecipeWithZeroAmountOutputReverts() (gas: 14870)
[PASS] testBurn() (gas: 56927)
[PASS] testBurnBatch() (gas: 88824)
[PASS] testBurnMoreThanBalance() (gas: 50390)
[PASS] testBurnUnauthorized() (gas: 51989)
[PASS] testCraftItemRevertsIfInsufficientInputs() (gas: 202106)
[PASS] testCraftItemRevertsIfRecipeDoesNotExist() (gas: 15404)
[PASS] testInitialization() (gas: 13070)
[PASS] testMint() (gas: 46981)
[PASS] testMintBatch() (gas: 73239)
[PASS] testMintBatchUnauthorized() (gas: 17858)
[PASS] testMintRevertsIfAmountZero() (gas: 18486)
[PASS] testMintRevertsIfNotMinter() (gas: 16197)
[PASS] testMintToZeroAddress() (gas: 16396)
[PASS] testPauseUnauthorized() (gas: 13378)
[PASS] testPauseUnpause() (gas: 62379)
[PASS] testSetItemUri() (gas: 41518)
[PASS] testSetItemUriAdmin() (gas: 41500)
[PASS] testSetItemUriUnauthorized() (gas: 13853)
[PASS] testSupportsInterface() (gas: 7111)
[PASS] testUnpauseUnauthorized() (gas: 42486)
Suite result: ok. 23 passed; 0 failed; 0 skipped; finished in 3.29s (15.78ms CPU time)

Ran 18 tests for test/GameAMM.t.sol:GameAMMTest
[PASS] testAddLiquidity() (gas: 182690)
[PASS] testAddLiquidityInitialShares() (gas: 179560)
[PASS] testAddLiquidityInsufficientX() (gas: 57109)
[PASS] testAddLiquidityInsufficientY() (gas: 92508)
[PASS] testAddLiquidityRatioMismatch() (gas: 198379)
[PASS] testAddLiquidityZeroAmountReverts() (gas: 67660)
[PASS] testFeeCalculation() (gas: 181207)
[PASS] testGetAmountOutX() (gas: 180778)
[PASS] testGetAmountOutY() (gas: 180779)
[PASS] testRemoveLiquidity() (gas: 166357)
[PASS] testRemoveLiquidityZeroReverts() (gas: 16191)
[PASS] testSwap() (gas: 216181)
[PASS] testSwapInsufficientLiquidityReverts() (gas: 195554)
[PASS] testSwapInvalidTokenReverts() (gas: 16516)
[PASS] testSwapRevertsOnHighSlippage() (gas: 203127)
[PASS] testSwapSameTokenReverts() (gas: 186282)
[PASS] testSwapY() (gas: 216198)
[PASS] testSwapZeroInputReverts() (gas: 18603)
Suite result: ok. 18 passed; 0 failed; 0 skipped; finished in 3.63s (11.82ms CPU time)

Ran 5 tests for test/Invariants.t.sol:InvariantsTest
[PASS] invariant_kProductNeverDecreases() (runs: 256, calls: 3840, reverts: 0)

╭------------------+---------------+-------+---------+----------╮
| Contract         | Selector      | Calls | Reverts | Discards |
+===============================================================+
| InvariantHandler | addLiquidity  | 794   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | depositVault  | 754   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapX         | 784   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapY         | 749   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | withdrawVault | 759   | 0       | 0        |
╰------------------+---------------+-------+---------+----------╯

[PASS] invariant_lpSupplyCorrespondsToReserves() (runs: 256, calls: 3840, reverts: 0)

╭------------------+---------------+-------+---------+----------╮
| Contract         | Selector      | Calls | Reverts | Discards |
+===============================================================+
| InvariantHandler | addLiquidity  | 794   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | depositVault  | 754   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapX         | 784   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapY         | 749   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | withdrawVault | 759   | 0       | 0        |
╰------------------+---------------+-------+---------+----------╯

[PASS] invariant_reservesMatchBalance() (runs: 256, calls: 3840, reverts: 0)

╭------------------+---------------+-------+---------+----------╮
| Contract         | Selector      | Calls | Reverts | Discards |
+===============================================================+
| InvariantHandler | addLiquidity  | 794   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | depositVault  | 754   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapX         | 784   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapY         | 749   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | withdrawVault | 759   | 0       | 0        |
╰------------------+---------------+-------+---------+----------╯

[PASS] invariant_tokenTotalSupply() (runs: 256, calls: 3840, reverts: 0)

╭------------------+---------------+-------+---------+----------╮
| Contract         | Selector      | Calls | Reverts | Discards |
+===============================================================+
| InvariantHandler | addLiquidity  | 794   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | depositVault  | 754   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapX         | 784   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapY         | 749   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | withdrawVault | 759   | 0       | 0        |
╰------------------+---------------+-------+---------+----------╯

[PASS] invariant_vaultBalanceCorrect() (runs: 256, calls: 3840, reverts: 0)

╭------------------+---------------+-------+---------+----------╮
| Contract         | Selector      | Calls | Reverts | Discards |
+===============================================================+
| InvariantHandler | addLiquidity  | 794   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | depositVault  | 754   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapX         | 784   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | swapY         | 749   | 0       | 0        |
|------------------+---------------+-------+---------+----------|
| InvariantHandler | withdrawVault | 759   | 0       | 0        |
╰------------------+---------------+-------+---------+----------╯

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 6.34s (19.51s CPU time)

Ran 8 test suites in 6.35s (15.60s CPU time): 117 tests passed, 0 failed, 0 skipped (117 total tests)
