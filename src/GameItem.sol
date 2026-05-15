// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract GameItem is ERC1155, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public itemIdCounter;

    mapping(uint256 => string) public itemMetadata;

    event ItemMinted(address indexed to, uint256 indexed tokenId, uint256 amount);
    event ItemBurned(address indexed from, uint256 indexed tokenId, uint256 amount);
    event ItemUriUpdated(uint256 indexed tokenId, string newUri);
    event ItemCrafted(
        uint256 indexed recipeId,
        address indexed user,
        uint256[] inputIds,
        uint256[] inputAmounts,
        uint256 outputId,
        uint256 outputAmount
    );

    struct Recipe {
        uint256[] inputIds;
        uint256[] inputAmounts;
        uint256 outputId;
        uint256 outputAmount;
        bool exists;
    }

    mapping(uint256 => Recipe) public recipes;
    uint256 public recipeCount;

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        // Initialize with 10 fungible crafting materials (IDs 1-10)
        // Amount: 100 each (with 18 decimals) — enough to test all features
        // without causing UI BigInt overflow in the frontend.
        for (uint256 i = 1; i <= 10; i++) {
            _mint(msg.sender, i, 100 * 10 ** 18, "");
        }
        itemIdCounter = 11;
    }

    function mint(address to, uint256 tokenId, uint256 amount, bytes memory data)
        external
        onlyRole(MINTER_ROLE)
        whenNotPaused
    {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be > 0");
        _mint(to, tokenId, amount, data);
        emit ItemMinted(to, tokenId, amount);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyRole(MINTER_ROLE)
        whenNotPaused
    {
        require(to != address(0), "Invalid address");
        _mintBatch(to, ids, amounts, data);
    }

    function burn(address from, uint256 tokenId, uint256 amount) external onlyRole(BURNER_ROLE) {
        require(balanceOf(from, tokenId) >= amount, "Insufficient balance");
        _burn(from, tokenId, amount);
        emit ItemBurned(from, tokenId, amount);
    }

    function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) external onlyRole(BURNER_ROLE) {
        _burnBatch(from, ids, amounts);
    }

    function setItemUri(uint256 tokenId, string memory _uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        itemMetadata[tokenId] = _uri;
        emit ItemUriUpdated(tokenId, _uri);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return itemMetadata[tokenId];
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function addRecipe(
        uint256[] calldata inputIds,
        uint256[] calldata inputAmounts,
        uint256 outputId,
        uint256 outputAmount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(inputIds.length == inputAmounts.length, "Inputs length mismatch");
        require(inputIds.length > 0, "No inputs provided");
        require(outputAmount > 0, "Output amount must be > 0");

        recipeCount++;
        recipes[recipeCount] = Recipe({
            inputIds: inputIds, inputAmounts: inputAmounts, outputId: outputId, outputAmount: outputAmount, exists: true
        });
    }

    function craftItem(uint256 recipeId) external whenNotPaused {
        Recipe storage recipe = recipes[recipeId];
        require(recipe.exists, "Recipe does not exist");

        // Burn inputs
        for (uint256 i = 0; i < recipe.inputIds.length; i++) {
            _burn(msg.sender, recipe.inputIds[i], recipe.inputAmounts[i]);
        }

        // Mint output
        _mint(msg.sender, recipe.outputId, recipe.outputAmount, "");

        emit ItemCrafted(
            recipeId, msg.sender, recipe.inputIds, recipe.inputAmounts, recipe.outputId, recipe.outputAmount
        );
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
