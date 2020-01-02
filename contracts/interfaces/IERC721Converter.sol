pragma solidity ^0.5.0;

interface IERC721Converter /* is IERC721TokenReceiver */{
    function draftAliceToken(uint256 _aliceTokenId, uint256 _bobTokenId) external;
    function draftBobToken(uint256 _BobTokenId, uint256 _aliceTokenId) external;
    function getAliceTokenID(uint256 _bobTokenId) external view returns(uint256);
    function getBobTokenID(uint256 _aliceTokenId) external view returns(uint256);
    function convertFromAliceToBob(uint256 _tokenId) external;
    function convertFromBobToAlice(uint256 _tokenId) external;
}
