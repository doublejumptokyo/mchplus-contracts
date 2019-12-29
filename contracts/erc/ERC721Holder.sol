pragma solidity ^0.5.0;

import "../interfaces/IERC721TokenReceiver.sol";

contract ERC721Holder is IERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
