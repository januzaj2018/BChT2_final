Ran 1 test for test/GovernanceE2E.t.sol:GovernanceE2E
[PASS] testFullGovernanceLifecycle() (gas: 417686)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 23.21ms (4.68ms CPU time)

Ran 23 tests for test/GameItem.t.sol:GameItemTest
[PASS] testAddRecipeAndCraft() (gas: 331013)
[PASS] testAddRecipeUnauthorized() (gas: 16643)
[PASS] testAddRecipeWithZeroAmountOutputReverts() (gas: 17050)
[PASS] testBurn() (gas: 62692)
[PASS] testBurnBatch() (gas: 101635)
[PASS] testBurnMoreThanBalance() (gas: 54582)
[PASS] testBurnUnauthorized() (gas: 56230)
[PASS] testCraftItemRevertsIfInsufficientInputs() (gas: 205484)
[PASS] testCraftItemRevertsIfRecipeDoesNotExist() (gas: 16503)
[PASS] testInitialization() (gas: 14358)
[PASS] testMint() (gas: 50676)
[PASS] testMintBatch() (gas: 79959)
[PASS] testMintBatchUnauthorized() (gas: 20411)
[PASS] testMintRevertsIfAmountZero() (gas: 20543)
[PASS] testMintRevertsIfNotMinter() (gas: 18041)
[PASS] testMintToZeroAddress() (gas: 18430)
[PASS] testPauseUnauthorized() (gas: 13789)
[PASS] testPauseUnpause() (gas: 69341)
[PASS] testSetItemUri() (gas: 44477)
[PASS] testSetItemUriAdmin() (gas: 44436)
[PASS] testSetItemUriUnauthorized() (gas: 15172)
[PASS] testSupportsInterface() (gas: 8455)
[PASS] testUnpauseUnauthorized() (gas: 43407)
Suite result: ok. 23 passed; 0 failed; 0 skipped; finished in 45.03ms (55.64ms CPU time)

Ran 3 tests for test/Fork.t.sol:ForkTest
[PASS] testForkChainlinkDecimals() (gas: 2356)
[PASS] testForkETHPrice() (gas: 2357)
[PASS] testForkWETHBalance() (gas: 2313)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 1.44s (1.83ms CPU time)

Ran 31 tests for test/GameFiExtra.t.sol:GameFiExtraTest
[PASS] testAddRecipeEmptyInputsReverts() (gas: 16183)
[PASS] testCastVote() (gas: 264842)
[PASS] testDepositNFT() (gas: 189936)
[PASS] testDepositNFTUnauthorized() (gas: 84652)
[PASS] testGovernorParams() (gas: 26295)
[PASS] testGovernorQueueAndExecute() (gas: 481481)
[PASS] testGovernorVotingDelay() (gas: 8037)
[PASS] testGovernorVotingPeriod() (gas: 8066)
[PASS] testLootDrop() (gas: 149292)
[PASS] testLootRequestUnauthorized() (gas: 13852)
[PASS] testLootVRFGameItemMatches() (gas: 8157)
[PASS] testLootVRFMultipleRequests() (gas: 135729)
[PASS] testLootVRFUnauthorizedFulfill() (gas: 79305)
[PASS] testPriceFeed() (gas: 16913)
[PASS] testPriceFeedSetPrice() (gas: 19592)
[PASS] testProposalThreshold() (gas: 15282)
[PASS] testPropose() (gas: 202591)
[PASS] testRentalVaultAssetMatches() (gas: 8111)
[PASS] testSetYieldRate() (gas: 23294)
[PASS] testStalePrice() (gas: 26265)
[PASS] testTimelockAdmin() (gas: 9995)
[PASS] testTimelockMinDelayValue() (gas: 8025)
[PASS] testTokenDelegation() (gas: 135749)
[PASS] testTokenMint() (gas: 62148)
[PASS] testTokenSymbol() (gas: 13417)
[PASS] testTokenTransfer() (gas: 94550)
[PASS] testUpdateYield() (gas: 9217)
[PASS] testWithdrawNFTCooldown() (gas: 233972)
[PASS] testWithdrawNFTExceedBalance() (gas: 215732)
[PASS] testWithdrawNFTZeroShares() (gas: 18744)
[PASS] testYieldSimulation() (gas: 205493)
Suite result: ok. 31 passed; 0 failed; 0 skipped; finished in 6.97s (205.96ms CPU time)

Ran 26 tests for test/AdvancedFeatures.t.sol:AdvancedFeaturesTest
[PASS] testAccessControlBlocksUnauthorizedBurn() (gas: 3968532)
[PASS] testAccessControlBlocksUnauthorizedMint() (gas: 3975786)
[PASS] testAccessControlGrantAndRevoke() (gas: 3719996)
[PASS] testFactoryCountIncrementsForBothMethods() (gas: 7525992)
[PASS] testFactoryCreate2IsDeterministic() (gas: 3791851)
[PASS] testFactoryCreate2SameSaltReverts() (gas: 1040547471)
[PASS] testFactoryCreateDeploysNewContract() (gas: 3779395)
[PASS] testFactoryCreateReturnsDifferentAddresses() (gas: 7520489)
[PASS] testFactoryGetDeployedItemOutOfBoundsReverts() (gas: 11680)
[PASS] testProposalThresholdIsOnePercent() (gas: 123598)
[PASS] testProposalThresholdZeroWhenNoSupply() (gas: 12803)
[PASS] testReentrancyAttackBlocked() (gas: 614121)
[PASS] testUUPSStoragePreservedAfterUpgrade() (gas: 139684)
[PASS] testUUPSUpgradeToV2() (gas: 35841)
[PASS] testUUPSUpgradeUnauthorizedReverts() (gas: 22538)
[PASS] testUUPSV1DelegateAndVotes() (gas: 195617)
[PASS] testUUPSV1MintUnauthorizedReverts() (gas: 19765)
[PASS] testUUPSV1MintWorks() (gas: 121385)
[PASS] testUUPSV1NameAndSymbol() (gas: 25065)
[PASS] testUUPSV2BurnWorks() (gas: 150647)
[PASS] testUUPSV2PauseBlocksTransfers() (gas: 201249)
[PASS] testUUPSV2UnpauseResumesTransfers() (gas: 214178)
[PASS] testYulAndSolidityHexProduceSameResult() (gas: 5415688)
[PASS] testYulAssemblyGasBenchmark() (gas: 5420427)
[PASS] testYulHexStringMaxUint() (gas: 5416391)
[PASS] testYulHexStringZero() (gas: 5392069)
Suite result: ok. 26 passed; 0 failed; 0 skipped; finished in 6.97s (229.05ms CPU time)

Ran 10 tests for test/Fuzz.t.sol:FuzzTest
[PASS] testFuzzAMMGetAmountOut(uint256) (runs: 256, μ: 20910, ~: 20318)
[PASS] testFuzzDeposit(uint256) (runs: 256, μ: 203012, ~: 202420)
[PASS] testFuzzGameItemBurn(uint256) (runs: 256, μ: 46437, ~: 45920)
[PASS] testFuzzGameItemMint(uint256) (runs: 256, μ: 51912, ~: 51237)
[PASS] testFuzzPriceFeed(int256) (runs: 256, μ: 25235, ~: 24762)
[PASS] testFuzzRentalVaultSetYieldRate(uint256) (runs: 256, μ: 22305, ~: 22883)
[PASS] testFuzzSwap(uint256) (runs: 256, μ: 113492, ~: 113810)
[PASS] testFuzzTokenTransfer(uint256) (runs: 256, μ: 120940, ~: 120348)
[PASS] testFuzzVaultRedeem(uint256) (runs: 256, μ: 240610, ~: 240732)
[PASS] testFuzzVoteWeight(uint256) (runs: 256, μ: 188400, ~: 187808)
Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 7.11s (16.74s CPU time)

Ran 18 tests for test/GameAMM.t.sol:GameAMMTest
[PASS] testAddLiquidity() (gas: 188728)
[PASS] testAddLiquidityInitialShares() (gas: 184600)
[PASS] testAddLiquidityInsufficientX() (gas: 61005)
[PASS] testAddLiquidityInsufficientY() (gas: 97159)
[PASS] testAddLiquidityRatioMismatch() (gas: 209258)
[PASS] testAddLiquidityZeroAmountReverts() (gas: 71019)
[PASS] testFeeCalculation() (gas: 188380)
[PASS] testGetAmountOutX() (gas: 187548)
[PASS] testGetAmountOutY() (gas: 187534)
[PASS] testRemoveLiquidity() (gas: 177086)
[PASS] testRemoveLiquidityZeroReverts() (gas: 17655)
[PASS] testSwap() (gas: 229156)
[PASS] testSwapInsufficientLiquidityReverts() (gas: 202853)
[PASS] testSwapInvalidTokenReverts() (gas: 18309)
[PASS] testSwapRevertsOnHighSlippage() (gas: 212869)
[PASS] testSwapSameTokenReverts() (gas: 193148)
[PASS] testSwapY() (gas: 229131)
[PASS] testSwapZeroInputReverts() (gas: 20443)
Suite result: ok. 18 passed; 0 failed; 0 skipped; finished in 7.11s (50.85ms CPU time)

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

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 11.53s (37.94s CPU time)

Ran 8 test suites in 11.54s (41.20s CPU time): 117 tests passed, 0 failed, 0 skipped (117 total tests)

╭--------------------------------------+------------------+------------------+----------------+-----------------╮
| File                                 | % Lines          | % Statements     | % Branches     | % Funcs         |
+===============================================================================================================+
| script/ConfigureRolesSepolia.s.sol   | 0.00% (0/19)     | 0.00% (0/23)     | 100.00% (0/0)  | 0.00% (0/1)     |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| script/Deploy.s.sol                  | 0.00% (0/68)     | 0.00% (0/70)     | 0.00% (0/2)    | 0.00% (0/4)     |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| script/GovernanceLifecycleDemo.s.sol | 0.00% (0/85)     | 0.00% (0/106)    | 0.00% (0/2)    | 0.00% (0/1)     |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| script/VerifyDeployment.s.sol        | 0.00% (0/52)     | 0.00% (0/61)     | 0.00% (0/30)   | 0.00% (0/1)     |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameAMM.sol                      | 100.00% (50/50)  | 100.00% (55/55)  | 87.50% (14/16) | 100.00% (6/6)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameGovernor.sol                 | 80.00% (16/20)   | 80.00% (16/20)   | 100.00% (0/0)  | 80.00% (8/10)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameItem.sol                     | 100.00% (46/46)  | 100.00% (39/39)  | 87.50% (14/16) | 100.00% (12/12) |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameItemFactory.sol              | 100.00% (44/44)  | 100.00% (46/46)  | 100.00% (3/3)  | 100.00% (8/8)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameToken.sol                    | 77.78% (7/9)     | 66.67% (4/6)     | 100.00% (0/0)  | 75.00% (3/4)    |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameTokenV1.sol                  | 88.24% (15/17)   | 83.33% (10/12)   | 100.00% (0/0)  | 83.33% (5/6)    |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/GameTokenV2.sol                  | 100.00% (15/15)  | 100.00% (9/9)    | 100.00% (2/2)  | 100.00% (6/6)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/LootVRF.sol                      | 100.00% (18/18)  | 100.00% (16/16)  | 50.00% (1/2)   | 100.00% (3/3)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/PriceFeed.sol                    | 85.71% (12/14)   | 81.82% (9/11)    | 66.67% (4/6)   | 75.00% (3/4)    |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/RentalVault.sol                  | 89.47% (51/57)   | 92.42% (61/66)   | 83.33% (10/12) | 75.00% (9/12)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| src/interfaces/VRFConsumerBaseV2.sol | 100.00% (6/6)    | 100.00% (4/4)    | 100.00% (1/1)  | 100.00% (2/2)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| test/AdvancedFeatures.t.sol          | 64.29% (9/14)    | 55.56% (5/9)     | 0.00% (0/2)    | 80.00% (4/5)    |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| test/GameAMM.t.sol                   | 100.00% (2/2)    | 100.00% (1/1)    | 100.00% (0/0)  | 100.00% (1/1)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| test/Handlers.sol                    | 100.00% (37/37)  | 100.00% (32/32)  | 100.00% (1/1)  | 100.00% (6/6)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| test/Mocks.sol                       | 51.16% (22/43)   | 66.67% (16/24)   | 50.00% (1/2)   | 35.00% (7/20)   |
|--------------------------------------+------------------+------------------+----------------+-----------------|
| Total                                | 56.82% (350/616) | 52.95% (323/610) | 52.58% (51/97) | 74.11% (83/112) |
╰--------------------------------------+------------------+------------------+----------------+-----------------╯
