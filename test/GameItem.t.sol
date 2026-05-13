// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/GameItem.sol";

contract GameItemTest is Test {
    GameItem public gameItem;
    address public admin = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    function setUp() public {
        vm.startPrank(admin);
        gameItem = new GameItem();
        vm.stopPrank();
    }

    function testInitialization() public {
        assertEq(gameItem.itemIdCounter(), 11);
        assertEq(gameItem.balanceOf(admin, 1), 1_000_000 * 10 ** 18);
    }

    function testMint() public {
        vm.prank(admin);
        gameItem.mint(user1, 11, 100, "");
        assertEq(gameItem.balanceOf(user1, 11), 100);
    }

    function testMintRevertsIfNotMinter() public {
        vm.prank(user1);
        vm.expectRevert();
        gameItem.mint(user2, 11, 100, "");
    }

    function testMintRevertsIfAmountZero() public {
        vm.prank(admin);
        vm.expectRevert("Amount must be > 0");
        gameItem.mint(user1, 11, 0, "");
    }

    function testBurn() public {
        vm.prank(admin);
        gameItem.mint(user1, 11, 100, "");

        vm.prank(admin);
        gameItem.burn(user1, 11, 50);
        assertEq(gameItem.balanceOf(user1, 11), 50);
    }

    function testSetItemUri() public {
        vm.prank(admin);
        gameItem.setItemUri(1, "https://example.com/1.json");
        assertEq(gameItem.uri(1), "https://example.com/1.json");
    }

    function testPauseUnpause() public {
        vm.prank(admin);
        gameItem.pause();
        assertTrue(gameItem.paused());

        vm.expectRevert();
        vm.prank(admin);
        gameItem.mint(user1, 11, 100, "");

        vm.prank(admin);
        gameItem.unpause();
        assertFalse(gameItem.paused());

        vm.prank(admin);
        gameItem.mint(user1, 11, 100, "");
        assertEq(gameItem.balanceOf(user1, 11), 100);
    }

    function testAddRecipeAndCraft() public {
        uint256[] memory inputIds = new uint256[](2);
        inputIds[0] = 1;
        inputIds[1] = 2;

        uint256[] memory inputAmounts = new uint256[](2);
        inputAmounts[0] = 10;
        inputAmounts[1] = 5;

        vm.prank(admin);
        gameItem.addRecipe(inputIds, inputAmounts, 11, 1);

        vm.prank(admin);
        gameItem.safeTransferFrom(admin, user1, 1, 10, "");
        vm.prank(admin);
        gameItem.safeTransferFrom(admin, user1, 2, 5, "");

        vm.prank(user1);
        gameItem.craftItem(1);

        assertEq(gameItem.balanceOf(user1, 11), 1);
        assertEq(gameItem.balanceOf(user1, 1), 0);
        assertEq(gameItem.balanceOf(user1, 2), 0);
    }

    function testCraftItemRevertsIfRecipeDoesNotExist() public {
        vm.prank(user1);
        vm.expectRevert("Recipe does not exist");
        gameItem.craftItem(999);
    }

    function testCraftItemRevertsIfInsufficientInputs() public {
        uint256[] memory inputIds = new uint256[](1);
        inputIds[0] = 1;
        uint256[] memory inputAmounts = new uint256[](1);
        inputAmounts[0] = 10;

        vm.prank(admin);
        gameItem.addRecipe(inputIds, inputAmounts, 11, 1);

        vm.prank(user1);
        vm.expectRevert();
        gameItem.craftItem(1);
    }

    function testSetItemUriUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert();
        gameItem.setItemUri(1, "ipfs://new");
    }

    function testMintBatch() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        vm.prank(admin);
        gameItem.mintBatch(user1, ids, amounts, "");
        assertEq(gameItem.balanceOf(user1, 1), 100);
        assertEq(gameItem.balanceOf(user1, 2), 200);
    }

    function testBurnBatch() public {
        testMintBatch();
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 50;
        amounts[1] = 100;

        vm.prank(admin);
        gameItem.burnBatch(user1, ids, amounts);
        assertEq(gameItem.balanceOf(user1, 1), 50);
        assertEq(gameItem.balanceOf(user1, 2), 100);
    }

    function testSupportsInterface() public {
        assertTrue(gameItem.supportsInterface(0xd9b67a26)); // ERC1155
        assertTrue(gameItem.supportsInterface(0x7965db0b)); // AccessControl
    }

    function testPauseUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert();
        gameItem.pause();
    }

    function testUnpauseUnauthorized() public {
        vm.prank(admin);
        gameItem.pause();
        vm.prank(user1);
        vm.expectRevert();
        gameItem.unpause();
    }

    function testMintToZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert("Invalid address");
        gameItem.mint(address(0), 11, 100, "");
    }

    function testAddRecipeUnauthorized() public {
        uint256[] memory inputIds = new uint256[](1);
        uint256[] memory inputAmounts = new uint256[](1);
        vm.prank(user1);
        vm.expectRevert();
        gameItem.addRecipe(inputIds, inputAmounts, 11, 1);
    }
}
