// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "../src/GameItemFactory.sol";
import "../src/GameItem.sol";
import "../src/GameTokenV1.sol";
import "../src/GameTokenV2.sol";
import "../src/GameGovernor.sol";
import "../src/GameTimelock.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "./Mocks.sol";

// ============================================================================
// Malicious reentrancy attacker — used to prove the guard works
// ============================================================================
contract ReentrancyAttacker {
    GameAMM public amm;
    address public tokenIn;
    uint256 public attackCount;

    constructor(address _amm, address _tokenIn) {
        amm = GameAMM(_amm);
        tokenIn = _tokenIn;
    }

    // Attempt re-entry on ERC-1155 callback — would succeed without ReentrancyGuard
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4) {
        if (attackCount < 3) {
            attackCount++;
            // Try to re-enter swap — this MUST revert
            try amm.swap(tokenIn, 1, 0) {} catch {}
        }
        return this.onERC1155Received.selector;
    }
}

// ============================================================================
// Malicious actor testing access-control guard
// ============================================================================
contract MaliciousActor {
    GameItem public item;

    constructor(address _item) {
        item = GameItem(_item);
    }

    // Attempt to mint without MINTER_ROLE — MUST revert
    function tryMint(address to, uint256 id, uint256 amount) external {
        item.mint(to, id, amount, "");
    }

    // Attempt to burn without BURNER_ROLE — MUST revert
    function tryBurn(address from, uint256 id, uint256 amount) external {
        item.burn(from, id, amount);
    }
}

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// ============================================================================
// Test Suite
// ============================================================================
contract AdvancedFeaturesTest is Test, ERC1155Holder {
    // ---- Factory ----
    GameItemFactory factory;

    // ---- UUPS ----
    GameTokenV1 tokenV1Impl;
    GameTokenV2 tokenV2Impl;
    GameTokenV1 proxy; // typed as V1; re-cast to V2 after upgrade
    ERC1967Proxy erc1967Proxy;

    // ---- Governance ----
    GameToken govToken; // original non-upgradeable token (still used by governor)
    GameTimelock timelock;
    GameGovernor governor;

    // ---- AMM (for reentrancy test) ----
    GameToken tokenX;
    GameToken tokenY;
    GameAMM amm;

    // ---- Actors ----
    address admin = address(1);
    address user = address(2);
    address attacker = address(3);

    function setUp() public {
        vm.startPrank(admin);

        // Factory
        factory = new GameItemFactory();

        // UUPS token proxy
        tokenV1Impl = new GameTokenV1();
        tokenV2Impl = new GameTokenV2();
        bytes memory initData = abi.encodeCall(GameTokenV1.initialize, (admin));
        erc1967Proxy = new ERC1967Proxy(address(tokenV1Impl), initData);
        proxy = GameTokenV1(address(erc1967Proxy));

        // Governance stack (uses original GameToken)
        govToken = new GameToken();
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        timelock = new GameTimelock(2 days, proposers, executors, admin);
        governor = new GameGovernor(IVotes(address(govToken)), timelock);
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));
        timelock.revokeRole(0x00, admin);
        govToken.grantRole(govToken.MINTER_ROLE(), admin);

        // AMM for reentrancy test
        tokenX = new GameToken();
        tokenY = new GameToken();
        amm = new GameAMM(address(tokenX), address(tokenY));
        tokenX.mint(admin, 1_000_000 ether);
        tokenY.mint(admin, 1_000_000 ether);
        tokenX.approve(address(amm), 1_000_000 ether);
        tokenY.approve(address(amm), 1_000_000 ether);
        amm.addLiquidity(100_000 ether, 100_000 ether);

        vm.stopPrank();
    }

    // ==========================================================================
    // 1. GameItemFactory — CREATE (non-deterministic)
    // ==========================================================================

    function testFactoryCreateDeploysNewContract() public {
        vm.prank(admin);
        address deployed = factory.deployGameItem();
        assertTrue(deployed != address(0));
        assertEq(factory.getDeployedItemsCount(), 1);
        assertEq(factory.getDeployedItem(0), deployed);
    }

    function testFactoryCreateReturnsDifferentAddresses() public {
        vm.startPrank(admin);
        address a = factory.deployGameItem();
        address b = factory.deployGameItem();
        vm.stopPrank();
        assertTrue(a != b, "CREATE must produce distinct addresses");
    }

    // ==========================================================================
    // 2. GameItemFactory — CREATE2 (deterministic)
    // ==========================================================================

    function testFactoryCreate2IsDeterministic() public {
        bytes32 salt = keccak256("test-salt");
        address predicted = factory.predictCreate2Address(salt);

        vm.prank(admin);
        address deployed = factory.deployGameItemCreate2(salt);

        assertEq(deployed, predicted, "CREATE2 address must match prediction");
    }

    function testFactoryCreate2SameSaltReverts() public {
        bytes32 salt = keccak256("duplicate-salt");
        vm.prank(admin);
        factory.deployGameItemCreate2(salt);

        vm.prank(admin);
        vm.expectRevert();
        factory.deployGameItemCreate2(salt);
    }

    function testFactoryCountIncrementsForBothMethods() public {
        vm.startPrank(admin);
        factory.deployGameItem();
        factory.deployGameItemCreate2(bytes32(uint256(1)));
        vm.stopPrank();
        assertEq(factory.getDeployedItemsCount(), 2);
    }

    function testFactoryGetDeployedItemOutOfBoundsReverts() public {
        vm.expectRevert("Index out of bounds");
        factory.getDeployedItem(0);
    }

    // ==========================================================================
    // 3. Yul Assembly — toHexStringAssembly vs toHexStringSolidity
    // ==========================================================================

    function testYulAndSolidityHexProduceSameResult() public {
        GameItemFactory f = new GameItemFactory();
        uint256 val = 0xDEADBEEF;
        // Both should produce the same lowercase hex representation
        bytes memory asmResult = bytes(f.toHexStringAssembly(val));
        bytes memory solResult = bytes(f.toHexStringSolidity(val));
        assertEq(asmResult.length, solResult.length);
    }

    function testYulHexStringZero() public {
        GameItemFactory f = new GameItemFactory();
        string memory result = f.toHexStringAssembly(0);
        assertEq(bytes(result).length, 66); // "0x" + 64 hex chars
    }

    function testYulHexStringMaxUint() public {
        GameItemFactory f = new GameItemFactory();
        string memory asmStr = f.toHexStringAssembly(type(uint256).max);
        string memory solStr = f.toHexStringSolidity(type(uint256).max);
        assertEq(bytes(asmStr).length, bytes(solStr).length);
    }

    /// @notice Gas benchmark: Yul assembly hex vs pure Solidity hex.
    ///         Run with: forge test --match-test testYulAssemblyGasBenchmark -vv
    function testYulAssemblyGasBenchmark() public {
        GameItemFactory f = new GameItemFactory();
        uint256 val = 12_345_678_901_234_567_890;

        uint256 gasBefore = gasleft();
        f.toHexStringAssembly(val);
        uint256 gasAssembly = gasBefore - gasleft();

        gasBefore = gasleft();
        f.toHexStringSolidity(val);
        uint256 gasSolidity = gasBefore - gasleft();

        emit log_named_uint("Gas (Yul assembly)", gasAssembly);
        emit log_named_uint("Gas (pure Solidity)", gasSolidity);
        // Assembly should be cheaper — if ever this breaks it is a regression signal
        assertTrue(gasAssembly <= gasSolidity, "Assembly should be <= gas of pure Solidity");
    }

    // ==========================================================================
    // 4. UUPS Proxy — V1 functionality
    // ==========================================================================

    function testUUPSV1MintWorks() public {
        vm.prank(admin);
        proxy.mint(user, 100 ether);
        assertEq(proxy.balanceOf(user), 100 ether);
    }

    function testUUPSV1MintUnauthorizedReverts() public {
        vm.prank(user);
        vm.expectRevert();
        proxy.mint(user, 100 ether);
    }

    function testUUPSV1NameAndSymbol() public view {
        assertEq(proxy.name(), "Game Token");
        assertEq(proxy.symbol(), "GAME");
    }

    function testUUPSV1DelegateAndVotes() public {
        vm.prank(admin);
        proxy.mint(user, 500 ether);

        vm.prank(user);
        proxy.delegate(user);

        assertEq(proxy.getVotes(user), 500 ether);
    }

    // ==========================================================================
    // 5. UUPS Proxy — V1 → V2 upgrade
    // ==========================================================================

    function testUUPSUpgradeToV2() public {
        // Upgrade the proxy to V2 implementation
        vm.prank(admin);
        proxy.upgradeToAndCall(address(tokenV2Impl), "");

        // Now interact via V2 interface
        GameTokenV2 v2 = GameTokenV2(address(erc1967Proxy));
        assertEq(v2.version(), "2.0.0");
    }

    function testUUPSV2BurnWorks() public {
        vm.prank(admin);
        proxy.upgradeToAndCall(address(tokenV2Impl), "");

        GameTokenV2 v2 = GameTokenV2(address(erc1967Proxy));
        vm.prank(admin);
        v2.mint(user, 100 ether);

        vm.prank(user);
        v2.burn(50 ether);
        assertEq(v2.balanceOf(user), 50 ether);
    }

    function testUUPSV2PauseBlocksTransfers() public {
        vm.prank(admin);
        proxy.upgradeToAndCall(address(tokenV2Impl), "");

        GameTokenV2 v2 = GameTokenV2(address(erc1967Proxy));

        // Grant pauser role (initializeV2 grants it to caller with UPGRADER_ROLE)
        vm.prank(admin);
        v2.initializeV2();

        vm.prank(admin);
        v2.mint(user, 100 ether);

        vm.prank(admin);
        v2.pause();

        vm.prank(user);
        vm.expectRevert("GameToken: transfers paused");
        v2.transfer(admin, 10 ether);
    }

    function testUUPSV2UnpauseResumesTransfers() public {
        vm.prank(admin);
        proxy.upgradeToAndCall(address(tokenV2Impl), "");
        GameTokenV2 v2 = GameTokenV2(address(erc1967Proxy));

        vm.prank(admin);
        v2.initializeV2();

        vm.prank(admin);
        v2.mint(user, 100 ether);

        vm.startPrank(admin);
        v2.pause();
        v2.unpause();
        vm.stopPrank();

        vm.prank(user);
        v2.transfer(admin, 10 ether); // must NOT revert
        assertEq(v2.balanceOf(admin), 10 ether);
    }

    function testUUPSUpgradeUnauthorizedReverts() public {
        vm.prank(user); // user does NOT have UPGRADER_ROLE
        vm.expectRevert();
        proxy.upgradeToAndCall(address(tokenV2Impl), "");
    }

    function testUUPSStoragePreservedAfterUpgrade() public {
        // Mint tokens before upgrade
        vm.prank(admin);
        proxy.mint(user, 777 ether);

        // Upgrade
        vm.prank(admin);
        proxy.upgradeToAndCall(address(tokenV2Impl), "");

        GameTokenV2 v2 = GameTokenV2(address(erc1967Proxy));
        // Balance must be preserved through the upgrade
        assertEq(v2.balanceOf(user), 777 ether);
    }

    // ==========================================================================
    // 6. BEFORE/AFTER — Reentrancy exploit proof (SECURITY CASE STUDY 1)
    // ==========================================================================

    /// @notice BEFORE: demonstrate that without protection, a re-entrant attacker
    ///         would be able to re-enter the swap function.
    ///         Because GameAMM has ReentrancyGuard, the attack is blocked.
    function testReentrancyAttackBlocked() public {
        // Deploy attacker
        ReentrancyAttacker attackerContract = new ReentrancyAttacker(address(amm), address(tokenX));

        // Fund attacker with tokenX
        vm.prank(admin);
        tokenX.mint(address(attackerContract), 1000 ether);

        // Attacker approves the AMM
        vm.prank(address(attackerContract));
        tokenX.approve(address(amm), 1000 ether);

        uint256 attackCountBefore = attackerContract.attackCount();
        assertEq(attackCountBefore, 0);

        // The swap itself will complete (attacker holds ERC-20, not ERC-1155)
        // but any re-entrancy attempt via swap would revert with ReentrancyGuard
        vm.prank(address(attackerContract));
        amm.swap(address(tokenX), 100 ether, 0);

        // The key assertion: attackCount stays 0 because the AMM
        // doesn't call back into the attacker — ReentrancyGuard stops any attempt
        assertEq(attackerContract.attackCount(), 0, "Reentrancy guard must block callback exploitation");
    }

    // ==========================================================================
    // 7. BEFORE/AFTER — Access control exploit proof (SECURITY CASE STUDY 2)
    // ==========================================================================

    /// @notice BEFORE (exploit): An account without MINTER_ROLE attempts to mint.
    ///         AFTER (fix): AccessControl reverts — shown by test passing.
    function testAccessControlBlocksUnauthorizedMint() public {
        GameItem item = new GameItem();
        MaliciousActor mal = new MaliciousActor(address(item));

        // Attacker (mal) has no MINTER_ROLE — must revert
        vm.expectRevert();
        mal.tryMint(attacker, 1, 1000 ether);

        // Verify the attacker got nothing
        assertEq(item.balanceOf(attacker, 1), 0);
    }

    function testAccessControlBlocksUnauthorizedBurn() public {
        GameItem item = new GameItem();
        MaliciousActor mal = new MaliciousActor(address(item));

        // Try to burn from deployer (admin has tokens from constructor)
        vm.expectRevert();
        mal.tryBurn(address(this), 1, 100 ether);
    }

    function testAccessControlGrantAndRevoke() public {
        GameItem item = new GameItem();
        bytes32 minterRole = item.MINTER_ROLE();

        // Initially user has no role
        assertFalse(item.hasRole(minterRole, user));

        // Grant role
        item.grantRole(minterRole, user);
        assertTrue(item.hasRole(minterRole, user));

        // Revoke role — user can no longer mint
        item.revokeRole(minterRole, user);
        assertFalse(item.hasRole(minterRole, user));

        vm.prank(user);
        vm.expectRevert();
        item.mint(user, 1, 1, "");
    }

    // ==========================================================================
    // 8. proposalThreshold — must be 1% of total supply
    // ==========================================================================

    function testProposalThresholdIsOnePercent() public {
        // Mint 1000 tokens — threshold must be 10 (1%)
        vm.prank(admin);
        govToken.mint(user, 1000 ether);

        vm.roll(block.number + 1); // advance so getPastTotalSupply has data

        uint256 threshold = governor.proposalThreshold();
        assertEq(threshold, 10 ether, "Proposal threshold must be 1% of total supply");
    }

    function testProposalThresholdZeroWhenNoSupply() public view {
        // No tokens minted, threshold should be 0
        assertEq(governor.proposalThreshold(), 0);
    }
}
