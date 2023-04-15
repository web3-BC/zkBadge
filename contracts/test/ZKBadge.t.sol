// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/ZKBadge.sol";

contract ZKBadgeTest is Test {
    ZKBadge badge;

    function setUp() public {
        badge = new ZKBadge();
    }

    function testIERC5192() public {
        assertTrue(badge.supportsInterface(type(IERC5192).interfaceId));
    }

    function testCallingLocked() public {
        address to = address(this);
        badge.mint(to, '');
        uint256 tokenId = badge.totalSupply();
        assertTrue(badge.locked(tokenId));
    }

    function testThrowingNotFoundError() public {
        vm.expectRevert(ZKBadge.ErrNotFound.selector);
        badge.locked(1000);
    }

    function testBlockedSafeTransferFrom() public {
        address to = address(this);
        badge.mint(to, '');
        uint tokenId = badge.totalSupply();

        bytes memory data;
        vm.expectRevert(ZKBadge.ErrLocked.selector);
        badge.safeTransferFrom(address(this), address(1), tokenId, data);

        vm.expectRevert(ZKBadge.ErrLocked.selector);
        badge.safeTransferFrom(address(this), address(1), tokenId);
    }

    function testBlockedTransferFrom() public {
        address to = address(this);
        badge.mint(to, '');
        uint256 tokenId = badge.totalSupply();

        vm.expectRevert(ZKBadge.ErrLocked.selector);
        badge.transferFrom(address(this), address(1), tokenId);
    }

    function testBlockedApprove() public {
        address to = address(this);
        badge.mint(to, '');
        uint256 tokenId = badge.totalSupply();

        vm.expectRevert(ZKBadge.ErrLocked.selector);
        badge.approve(address(1), tokenId);
    }

    function testBlockedSetApprovalForAll() public {
        vm.expectRevert(ZKBadge.ErrLocked.selector);
        badge.setApprovalForAll(address(1), true);
    }

    function testFailMintAsNotOwner() public {
        vm.prank(address(0));
        badge.mint(address(1), '');
    }

    function testTokenURI() public {
        address to = address(this);
        badge.mint(to, 'https://xxxx.com');

        assertEq(badge.tokenURI(1), 'https://xxxx.com');
    }

    function testGetOwnedToken() public {
        address to = address(this);
        badge.mint(to, 'https://xxxx.com');

        assertEq(badge.getOwnedToken(to), 1);
    }

    // TODO: addVerifier
}
