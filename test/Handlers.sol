// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameAMM.sol";
import "../src/RentalVault.sol";
import "../src/GameToken.sol";
import "../src/GameItem.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InvariantHandler is Test {
    GameAMM amm;
    RentalVault vault;
    GameToken token;
    GameItem item;
    ERC20 tokenX;
    ERC20 tokenY;

    constructor(
        GameAMM _amm,
        RentalVault _vault,
        GameToken _token,
        GameItem _item
    ) {
        amm = _amm;
        vault = _vault;
        token = _token;
        item = _item;
        tokenX = ERC20(address(amm.TOKEN_X()));
        tokenY = ERC20(address(amm.TOKEN_Y()));
    }

    function swapX(uint256 amountIn) public {
        amountIn = bound(amountIn, 1000, 1e20);
        deal(address(tokenX), address(this), amountIn);
        tokenX.approve(address(amm), amountIn);
        amm.swap(address(tokenX), amountIn, 0);
    }

    function swapY(uint256 amountIn) public {
        amountIn = bound(amountIn, 1000, 1e20);
        deal(address(tokenY), address(this), amountIn);
        tokenY.approve(address(amm), amountIn);
        amm.swap(address(tokenY), amountIn, 0);
    }

    function depositVault(uint256 amount) public {
        amount = bound(amount, 1, 1e20);
        token.mint(address(this), amount);
        token.approve(address(vault), amount);
        vault.deposit(amount, address(this));
    }

    function withdrawVault(uint256 shares) public {
        uint256 balance = vault.balanceOf(address(this));
        shares = bound(shares, 0, balance);
        if (shares > 0) {
            vm.warp(block.timestamp + 8 days);
            // Fund the vault with enough tokens to cover yield
            token.mint(address(vault), 1e30); 
            vault.withdraw(shares, address(this), address(this));
        }
    }

    function addLiquidity(uint256 amountX, uint256 amountY) public {
        amountX = bound(amountX, 1e6, 1e20);
        amountY = bound(amountY, 1e6, 1e20);
        deal(address(tokenX), address(this), amountX);
        deal(address(tokenY), address(this), amountY);
        tokenX.approve(address(amm), amountX);
        tokenY.approve(address(amm), amountY);
        amm.addLiquidity(amountX, amountY);
    }
}
