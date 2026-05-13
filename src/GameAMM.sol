// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract GameAMM is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable TOKEN_X;
    IERC20 public immutable TOKEN_Y;

    uint256 public reserveX;
    uint256 public reserveY;

    event LiquidityAdded(address indexed provider, uint256 amountX, uint256 amountY, uint256 lpTokens);
    event LiquidityRemoved(address indexed provider, uint256 amountX, uint256 amountY, uint256 lpTokens);
    event Swap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenX, address _tokenY) ERC20("Game AMM LP", "GAMM-LP") {
        require(_tokenX != address(0) && _tokenY != address(0), "Invalid token addresses");
        TOKEN_X = IERC20(_tokenX);
        TOKEN_Y = IERC20(_tokenY);
    }

    function addLiquidity(uint256 amountX, uint256 amountY) external nonReentrant returns (uint256 shares) {
        TOKEN_X.safeTransferFrom(msg.sender, address(this), amountX);
        TOKEN_Y.safeTransferFrom(msg.sender, address(this), amountY);

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            shares = Math.sqrt(amountX * amountY);
        } else {
            shares = Math.min(
                (amountX * _totalSupply) / reserveX,
                (amountY * _totalSupply) / reserveY
            );
        }

        require(shares > 0, "Insufficient shares minted");
        _mint(msg.sender, shares);

        _updateReserves();
        emit LiquidityAdded(msg.sender, amountX, amountY, shares);
    }

    function removeLiquidity(uint256 shares) external nonReentrant returns (uint256 amountX, uint256 amountY) {
        require(shares > 0, "Invalid shares amount");
        uint256 _totalSupply = totalSupply();

        amountX = (shares * reserveX) / _totalSupply;
        amountY = (shares * reserveY) / _totalSupply;

        require(amountX > 0 && amountY > 0, "Insufficient liquidity burned");

        _burn(msg.sender, shares);
        TOKEN_X.safeTransfer(msg.sender, amountX);
        TOKEN_Y.safeTransfer(msg.sender, amountY);

        _updateReserves();
        emit LiquidityRemoved(msg.sender, amountX, amountY, shares);
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(tokenIn == address(TOKEN_X) || tokenIn == address(TOKEN_Y), "Invalid token");
        require(amountIn > 0, "Invalid input amount");

        bool isX = tokenIn == address(TOKEN_X);
        (IERC20 _tokenIn, IERC20 _tokenOut, uint256 _reserveIn, uint256 _reserveOut) = isX 
            ? (TOKEN_X, TOKEN_Y, reserveX, reserveY) 
            : (TOKEN_Y, TOKEN_X, reserveY, reserveX);

        _tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);

        // Constant product formula: (x + dx) * (y - dy) = x * y
        // dx = amountIn, dy = amountOut
        // amountOut = (y * dx) / (x + dx)
        // With 0.3% fee: amountInWithFee = amountIn * 997 / 1000
        uint256 amountInWithFee = (amountIn * 997) / 1000;
        amountOut = (_reserveOut * amountInWithFee) / (_reserveIn + amountInWithFee);

        require(amountOut >= minAmountOut, "Slippage too high");
        _tokenOut.safeTransfer(msg.sender, amountOut);

        _updateReserves();
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    function _updateReserves() internal {
        reserveX = TOKEN_X.balanceOf(address(this));
        reserveY = TOKEN_Y.balanceOf(address(this));
    }

    function getAmountOut(uint256 amountIn, bool isX) external view returns (uint256 amountOut) {
        (uint256 _reserveIn, uint256 _reserveOut) = isX ? (reserveX, reserveY) : (reserveY, reserveX);
        uint256 amountInWithFee = (amountIn * 997) / 1000;
        return (_reserveOut * amountInWithFee) / (_reserveIn + amountInWithFee);
    }
}
