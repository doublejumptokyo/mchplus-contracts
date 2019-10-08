pragma solidity ^0.5.0;

import "./IERC721.sol";
import "./OperatorRole.sol";
import "./lib/github.com/OpenZeppelin/openzeppelin-solidity-2.3.0/contracts/token/ERC721/ERC721Holder.sol";

contract ERC721Converter is ERC721Holder, OperatorRole {
  ERC721 Alice;
  ERC721 Bob;

  address public aliceContract;
  address public bobContract;

  mapping (uint256 => uint256) private _idMapAliceToBob;
  mapping (uint256 => uint256) private _idMapBobToAlice;

  constructor(address _alice, address _bob) public {
    aliceContract = _alice;
    bobContract = _bob;
    Alice = ERC721(aliceContract);
    Bob = ERC721(bobContract);
  }

  function updateAlice(address _newAlice) external onlyOperator() {
    aliceContract = _newAlice;
    Alice = ERC721(_newAlice);
  }

  function updateBob(address _newBob) external onlyOperator() {
    bobContract = _newBob;
    Bob = ERC721(_newBob);
  }

  function draftAliceTokens(uint256[] memory _aliceTokenIds, uint256[] memory _bobTokenIds) public onlyOperator() {
    require(_aliceTokenIds.length == _bobTokenIds.length);
    for (uint256 i = 0; i < _aliceTokenIds.length; i++) {
      draftAliceToken(_aliceTokenIds[i], _bobTokenIds[i]);
    }
  }

  function draftBobTokens(uint256[] memory _bobTokenIds, uint256[] memory _aliceTokenIds) public onlyOperator() {
    require(_aliceTokenIds.length == _bobTokenIds.length);
    for (uint256 i = 0; i < _aliceTokenIds.length; i++) {
      draftBobToken(_bobTokenIds[i], _aliceTokenIds[i]);
    }
  }

  function draftAliceToken(uint256 _aliceTokenId, uint256 _bobTokenId) public onlyOperator() {
    require(Alice.ownerOf(_aliceTokenId) == address(this), "_aliceTokenId is not owned");
    require(_idMapAliceToBob[_aliceTokenId] == 0, "_aliceTokenId is already assignd");
    require(_idMapBobToAlice[_bobTokenId] == 0, "_bobTokenId is already assignd");

    _idMapAliceToBob[_aliceTokenId] = _bobTokenId;
    _idMapBobToAlice[_bobTokenId] = _aliceTokenId;
  }

  function draftBobToken(uint256 _bobTokenId, uint256 _aliceTokenId) public onlyOperator() {
    require(Bob.ownerOf(_bobTokenId) == address(this), "_bobTokenId is not owned");
    require(_idMapBobToAlice[_bobTokenId] == 0, "_bobTokenId is already assignd");
    require(_idMapAliceToBob[_aliceTokenId] == 0, "_aliceTokenId is already assignd");

    _idMapBobToAlice[_bobTokenId] = _aliceTokenId;
    _idMapAliceToBob[_aliceTokenId] = _bobTokenId;
  }

  function getBobTokenID(uint256 _aliceTokenId) public view returns(uint256) {
    return _idMapAliceToBob[_aliceTokenId];
  }

  function getAliceTokenID(uint256 _bobTokenId) public view returns(uint256) {
    return _idMapBobToAlice[_bobTokenId];
  }

  function convertFromAliceToBob(uint256 _tokenId) external whenNotPaused() {
    Alice.safeTransferFrom(msg.sender, address(this), _tokenId);
    Bob.safeTransferFrom(address(this), msg.sender, getBobTokenID(_tokenId));
  }

  function convertFromBobToAlice(uint256 _tokenId) external whenNotPaused() {
    Bob.safeTransferFrom(msg.sender, address(this), _tokenId);
    Alice.safeTransferFrom(address(this), msg.sender, getAliceTokenID(_tokenId));
  }
}
