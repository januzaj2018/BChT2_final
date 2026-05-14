// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./GameToken.sol";

contract RentalVault is ERC4626, ERC1155Holder, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC1155 public immutable gameItem;
    uint256 public immutable targetTokenId;

    uint256 public lastYieldUpdate;
    uint256 public yieldRate = 1000; // 10% annual in basis points (simplified)
    uint256 public constant BASIS_POINTS = 10_000;
    uint256 public constant SECONDS_PER_YEAR = 365 days;

    mapping(address => uint256) public depositTimestamp;
    uint256 public constant COOLDOWN = 7 days;

    event YieldUpdated(uint256 newRate);
    event NFTDeposited(address indexed user, uint256 tokenId, uint256 amount, uint256 shares);
    event NFTWithdrawn(address indexed user, uint256 tokenId, uint256 amount, uint256 shares);

    constructor(IERC20 _asset, IERC1155 _gameItem, uint256 _targetTokenId)
        ERC4626(_asset)
        ERC20("Game Rental Shares", "GRS")
        Ownable(msg.sender)
    {
        gameItem = _gameItem;
        targetTokenId = _targetTokenId;
        lastYieldUpdate = block.timestamp;
    }

    /**
     * @dev Total assets includes the underlying GameToken balance plus the value of deposited NFTs,
     * plus the accrued yield.
     */
    function totalAssets() public view override returns (uint256) {
        uint256 tokenBalance = IERC20(asset()).balanceOf(address(this));
        uint256 nftValue = gameItem.balanceOf(address(this), targetTokenId) * 10 ** 18;
        uint256 baseAssets = tokenBalance + nftValue;

        uint256 timeElapsed = block.timestamp - lastYieldUpdate;
        if (timeElapsed == 0) return baseAssets;

        uint256 yield = (totalSupply() * yieldRate * timeElapsed) / (BASIS_POINTS * SECONDS_PER_YEAR);
        return baseAssets + yield;
    }

    function syncYield() public {
        uint256 timeElapsed = block.timestamp - lastYieldUpdate;
        if (timeElapsed > 0 && totalSupply() > 0) {
            uint256 yield = (totalSupply() * yieldRate * timeElapsed) / (BASIS_POINTS * SECONDS_PER_YEAR);
            if (yield > 0) {
                // Try to mint yield if vault has MINTER_ROLE
                try GameToken(address(asset())).mint(address(this), yield) {} catch {}
            }
        }
        lastYieldUpdate = block.timestamp;
    }

    function deposit(uint256 assets, address receiver) public override nonReentrant returns (uint256) {
        syncYield();
        return super.deposit(assets, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner) public override nonReentrant returns (uint256) {
        syncYield();
        return super.withdraw(assets, receiver, owner);
    }

    function mint(uint256 shares, address receiver) public override nonReentrant returns (uint256) {
        syncYield();
        return super.mint(shares, receiver);
    }

    function redeem(uint256 shares, address receiver, address owner) public override nonReentrant returns (uint256) {
        syncYield();
        return super.redeem(shares, receiver, owner);
    }

    function updateYield() public {
        syncYield();
    }

    function depositNFT(uint256 amount) external nonReentrant returns (uint256 shares) {
        require(amount > 0, "Amount must be > 0");
        syncYield();

        // Determine share amount before transfer.
        uint256 virtualAssets = amount * 10 ** 18;
        shares = previewDeposit(virtualAssets);

        // Transfer NFT to vault
        gameItem.safeTransferFrom(msg.sender, address(this), targetTokenId, amount, "");

        _mint(msg.sender, shares);
        depositTimestamp[msg.sender] = block.timestamp;

        emit NFTDeposited(msg.sender, targetTokenId, amount, shares);
    }

    function withdrawNFT(uint256 shares) external nonReentrant returns (uint256 amount) {
        require(shares > 0, "Shares must be > 0");
        require(block.timestamp >= depositTimestamp[msg.sender] + COOLDOWN, "Cooldown active");
        syncYield();

        amount = (previewRedeem(shares)) / 10 ** 18;
        require(amount > 0, "Insufficient shares for 1 NFT");

        _burn(msg.sender, shares);
        gameItem.safeTransferFrom(address(this), msg.sender, targetTokenId, amount, "");

        emit NFTWithdrawn(msg.sender, targetTokenId, amount, shares);
    }

    function setYieldRate(uint256 _yieldRate) external onlyOwner {
        updateYield();
        yieldRate = _yieldRate;
        emit YieldUpdated(_yieldRate);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
