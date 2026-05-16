// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @title GameTokenV1
/// @notice ERC-20 governance token with ERC20Votes + ERC20Permit, deployed behind a UUPS proxy.
///         This is V1 of the upgradeable token. See GameTokenV2.sol for the upgrade path.
/// @dev    Storage layout is fixed here. Any V2 MUST only append new storage variables
///         after the existing ones to prevent storage collisions.
///
/// ## Storage Layout (V1)
/// Slot 0–N : inherited from ERC20Upgradeable, ERC20VotesUpgradeable, ERC20PermitUpgradeable,
///            AccessControlUpgradeable (all managed by OZ Initializable gaps).
/// No custom storage variables in V1 beyond constants (which are NOT stored in slots).
contract GameTokenV1 is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializer — replaces the constructor for upgradeable contracts.
    function initialize(address admin) public initializer {
        __ERC20_init("Game Token", "GAME");
        __ERC20Permit_init("Game Token");
        __ERC20Votes_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @dev Only accounts with UPGRADER_ROLE can upgrade the implementation.
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // Required overrides for OZ v5 multiple inheritance
    function _update(address from, address to, uint256 value)
        internal
        virtual
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20PermitUpgradeable, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }
}
