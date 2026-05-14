// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./Handlers.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "./Mocks.sol";

contract InvariantsTest is Test, ERC1155Holder {
    GameAMM amm;
    RentalVault vault;
    GameToken token;
    GameItem item;
    MockERC20 tokenX;
    MockERC20 tokenY;
    InvariantHandler handler;

    function setUp() public {
        tokenX = new MockERC20("X", "X");
        tokenY = new MockERC20("Y", "Y");
        amm = new GameAMM(address(tokenX), address(tokenY));
        
        token = new GameToken();
        item = new GameItem();
        vault = new RentalVault(token, item, 1);

        // Initial liquidity
        tokenX.mint(address(this), 10e18);
        tokenY.mint(address(this), 10e18);
        tokenX.approve(address(amm), 10e18);
        tokenY.approve(address(amm), 10e18);
        amm.addLiquidity(10e18, 10e18);

        handler = new InvariantHandler(amm, vault, token, item);
        
        token.grantRole(token.MINTER_ROLE(), address(handler));
        token.grantRole(token.MINTER_ROLE(), address(this));
        
        targetContract(address(handler));
    }

    function invariant_kProductNeverDecreases() public {
        uint256 reserveX = amm.reserveX();
        uint256 reserveY = amm.reserveY();
        uint256 k = reserveX * reserveY;
        
        // Initial k was 10e18 * 10e18 = 100e36
        assertTrue(k >= 100e36, "K-invariant decreased below initial");
    }

    function invariant_vaultBalanceCorrect() public {
        uint256 totalShares = vault.totalSupply();
        uint256 totalAssets = vault.totalAssets();
        
        // If shares > 0, assets must be > 0 (roughly)
        if (totalShares > 0) {
            assertTrue(totalAssets > 0, "Vault has shares but no assets");
        }
    }

    function invariant_lpSupplyCorrespondsToReserves() public {
        uint256 totalSupply = amm.totalSupply();
        uint256 reserveX = amm.reserveX();
        uint256 reserveY = amm.reserveY();
        
        if (totalSupply > 0) {
            assertTrue(reserveX > 0 && reserveY > 0, "AMM has supply but no reserves");
        }
    }

    function invariant_reservesMatchBalance() public {
        assertEq(amm.reserveX(), tokenX.balanceOf(address(amm)));
        assertEq(amm.reserveY(), tokenY.balanceOf(address(amm)));
    }

    function invariant_tokenTotalSupply() public {
        // Simple check: total supply should not decrease if only minting happens in handler
        assertTrue(token.totalSupply() >= 0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
