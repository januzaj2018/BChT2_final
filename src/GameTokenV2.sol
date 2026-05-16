// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./GameTokenV1.sol";

/// @title GameTokenV2
/// @notice V2 upgrade of the upgradeable GameToken. Demonstrates the UUPS V1 → V2 upgrade path.
///
/// ## V1 → V2 Upgrade Path
/// 1. Deploy GameTokenV2 implementation: `forge create src/GameTokenV2.sol:GameTokenV2`
/// 2. Call `proxy.upgradeToAndCall(newImpl, "")` from an account with UPGRADER_ROLE.
/// 3. The proxy storage is preserved; only the implementation logic changes.
///
/// ## Storage Safety
/// V2 MUST NOT reorder or remove any storage slots from V1.
/// Only new variables are added AFTER all existing V1 variables.
/// This contract inherits all V1 storage, so the layout is safe.
///
/// ## New Features in V2
/// - `pause()` / `unpause()` to freeze transfers during emergency
/// - `burn()` so holders can reduce their own balance
/// - `version()` view for on-chain version discovery
contract GameTokenV2 is GameTokenV1 {
    // -----------------------------------------------------------------------
    // NEW V2 storage — appended after all V1 storage slots
    // -----------------------------------------------------------------------
    bool public pausedV2; // V2 slot: comes after all inherited V1 slots

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event Paused(address account);
    event Unpaused(address account);

    // -----------------------------------------------------------------------
    // V2 initializer (called via upgradeToAndCall if needed)
    // -----------------------------------------------------------------------

    /// @notice V2 re-initializer — grants PAUSER_ROLE to the caller (must hold UPGRADER_ROLE).
    function initializeV2() public reinitializer(2) {
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    // -----------------------------------------------------------------------
    // V2 new functions
    // -----------------------------------------------------------------------

    function pause() external onlyRole(PAUSER_ROLE) {
        pausedV2 = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        pausedV2 = false;
        emit Unpaused(msg.sender);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// @notice Returns the semantic version string of this implementation.
    function version() external pure returns (string memory) {
        return "2.0.0";
    }

    // -----------------------------------------------------------------------
    // Override _update to enforce pause
    // -----------------------------------------------------------------------
    function _update(address from, address to, uint256 value) internal override(GameTokenV1) {
        require(!pausedV2 || from == address(0) || to == address(0), "GameToken: transfers paused");
        super._update(from, to, value);
    }
}
