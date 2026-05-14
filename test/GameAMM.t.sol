// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameAMM.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract GameAMMTest is Test {
    GameAMM public amm;
    MockERC20 public tokenX;
    MockERC20 public tokenY;

    address public user1 = address(1);
    address public user2 = address(2);

    function setUp() public {
        tokenX = new MockERC20("Token X", "TKX");
        tokenY = new MockERC20("Token Y", "TKY");

        amm = new GameAMM(address(tokenX), address(tokenY));

        tokenX.mint(user1, 1_000_000 * 10 ** 18);
        tokenY.mint(user1, 1_000_000 * 10 ** 18);

        tokenX.mint(user2, 1_000_000 * 10 ** 18);
        tokenY.mint(user2, 1_000_000 * 10 ** 18);

        vm.startPrank(user1);
        tokenX.approve(address(amm), type(uint256).max);
        tokenY.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenX.approve(address(amm), type(uint256).max);
        tokenY.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        vm.startPrank(user1);
        uint256 amountX = 1000 * 10 ** 18;
        uint256 amountY = 1000 * 10 ** 18;

        uint256 shares = amm.addLiquidity(amountX, amountY);

        assertEq(amm.reserveX(), amountX);
        assertEq(amm.reserveY(), amountY);
        assertEq(amm.balanceOf(user1), shares);
        assertTrue(shares > 0);
        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user1);
        uint256 amountX = 1000 * 10 ** 18;
        uint256 amountY = 1000 * 10 ** 18;

        uint256 shares = amm.addLiquidity(amountX, amountY);

        uint256 initialBalX = tokenX.balanceOf(user1);
        uint256 initialBalY = tokenY.balanceOf(user1);

        amm.removeLiquidity(shares);

        assertEq(tokenX.balanceOf(user1), initialBalX + amountX);
        assertEq(tokenY.balanceOf(user1), initialBalY + amountY);
        assertEq(amm.reserveX(), 0);
        assertEq(amm.reserveY(), 0);
        assertEq(amm.balanceOf(user1), 0);
        vm.stopPrank();
    }

    function testSwap() public {
        vm.prank(user1);
        amm.addLiquidity(10_000 * 10 ** 18, 10_000 * 10 ** 18);

        vm.startPrank(user2);
        uint256 amountIn = 100 * 10 ** 18;
        uint256 expectedOut = amm.getAmountOut(amountIn, true);

        uint256 initialBalY = tokenY.balanceOf(user2);

        uint256 amountOut = amm.swap(address(tokenX), amountIn, expectedOut);

        assertEq(amountOut, expectedOut);
        assertEq(tokenY.balanceOf(user2), initialBalY + amountOut);
        vm.stopPrank();
    }

    function testSwapRevertsOnHighSlippage() public {
        vm.prank(user1);
        amm.addLiquidity(10_000 * 10 ** 18, 10_000 * 10 ** 18);

        vm.startPrank(user2);
        uint256 amountIn = 100 * 10 ** 18;
        uint256 expectedOut = amm.getAmountOut(amountIn, true);

        vm.expectRevert("Slippage too high");
        amm.swap(address(tokenX), amountIn, expectedOut + 1);
        vm.stopPrank();
    }

    function testFeeCalculation() public {
        vm.prank(user1);
        amm.addLiquidity(10_000 * 10 ** 18, 10_000 * 10 ** 18);

        uint256 numerator = 10_000 * 10 ** 18 * 997;
        uint256 denominator = 100_997;
        uint256 expectedOut = numerator / denominator;

        assertApproxEqAbs(amm.getAmountOut(100 * 10 ** 18, true), expectedOut, 10 ** 15);
    }

    function testSwapY() public {
        vm.prank(user1);
        amm.addLiquidity(10_000 * 10 ** 18, 10_000 * 10 ** 18);

        vm.startPrank(user2);
        uint256 amountIn = 100 * 10 ** 18;
        uint256 expectedOut = amm.getAmountOut(amountIn, false);

        uint256 initialBalX = tokenX.balanceOf(user2);

        uint256 amountOut = amm.swap(address(tokenY), amountIn, expectedOut);

        assertEq(amountOut, expectedOut);
        assertEq(tokenX.balanceOf(user2), initialBalX + amountOut);
        vm.stopPrank();
    }

    function testGetAmountOutX() public {
        vm.prank(user1);
        amm.addLiquidity(10_000, 10_000);
        uint256 out = amm.getAmountOut(100, true);
        assertTrue(out > 0);
    }

    function testGetAmountOutY() public {
        vm.prank(user1);
        amm.addLiquidity(10_000, 10_000);
        uint256 out = amm.getAmountOut(100, false);
        assertTrue(out > 0);
    }

    function testSwapZeroInputReverts() public {
        vm.prank(user2);
        vm.expectRevert("Invalid input amount");
        amm.swap(address(tokenX), 0, 0);
    }

    function testSwapInvalidTokenReverts() public {
        vm.prank(user2);
        vm.expectRevert("Invalid token");
        amm.swap(address(0x123), 100, 0);
    }

    function testRemoveLiquidityZeroReverts() public {
        vm.prank(user2);
        vm.expectRevert("Invalid shares amount");
        amm.removeLiquidity(0);
    }

    function testAddLiquidityInitialShares() public {
        vm.startPrank(user1);
        uint256 shares = amm.addLiquidity(100, 400);
        assertEq(shares, 200); // sqrt(100 * 400) = 200
        vm.stopPrank();
    }

    function testAddLiquidityInsufficientX() public {
        vm.startPrank(user2);
        tokenX.transfer(address(3), tokenX.balanceOf(user2) - 50); // Leave only 50
        vm.expectRevert();
        amm.addLiquidity(100, 100);
        vm.stopPrank();
    }

    function testAddLiquidityInsufficientY() public {
        vm.startPrank(user2);
        tokenY.transfer(address(3), tokenY.balanceOf(user2) - 50); // Leave only 50
        vm.expectRevert();
        amm.addLiquidity(100, 100);
        vm.stopPrank();
    }

    function testAddLiquidityZeroAmountReverts() public {
        vm.startPrank(user1);
        vm.expectRevert("Insufficient shares minted");
        amm.addLiquidity(0, 100);
        vm.stopPrank();
    }

    function testSwapSameTokenReverts() public {
        vm.prank(user1);
        amm.addLiquidity(1000, 1000);

        vm.prank(user2);
        vm.expectRevert("Invalid token");
        amm.swap(address(0), 100, 0);
    }

    function testSwapInsufficientLiquidityReverts() public {
        vm.prank(user1);
        amm.addLiquidity(1000, 1000);

        vm.startPrank(user2);
        vm.expectRevert();
        amm.swap(address(tokenX), 1e25, 0);
        vm.stopPrank();
    }

    function testAddLiquidityRatioMismatch() public {
        vm.startPrank(user1);
        amm.addLiquidity(1000, 1000);
        amm.addLiquidity(1000, 2000);
        assertEq(amm.reserveX(), 2000);
        assertEq(amm.reserveY(), 3000);
        vm.stopPrank();
    }
}
