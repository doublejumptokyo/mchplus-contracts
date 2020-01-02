pragma solidity ^0.5.0;

import "../libraries/Uint256.sol";
import "../libraries/Address.sol";

import "../interfaces/IERC721.sol";
import "../interfaces/IERC721TokenReceiver.sol";
import "./ERC165.sol";

/// @title ERC721 Non-Fungible Token Standard basic implementation
/// @dev see https://eips.ethereum.org/EIPS/eip-721
contract ERC721 is IERC721, ERC165 {
    using Uint256 for uint256;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    mapping (uint256 => address) private _tokenOwner;
    mapping (address => uint256) private _balance;
    mapping (uint256 => address) private _tokenApproved;
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor () public {
        _registerInterface(_InterfaceId_ERC721);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balance[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        require(_exist(_tokenId),
                "`_tokenId` is not a valid NFT.");
        return _tokenOwner[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable {
        require(_data.length == 0, "data is not implemented");
        safeTransferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        require(_checkOnERC721Received(_from, _to, _tokenId, ""),
                "`_to` is a smart contract and onERC721Received is invalid");
        transferFrom(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        require(_transferable(msg.sender, _tokenId),
                "Unless `msg.sender` is the current owner, an authorized operator, or the approved address for this NFT."); // solhint-disable-line
        require(ownerOf(_tokenId) == _from,
                "`_from` is not the current owner.");
        require(_to != address(0),
                "`_to` is the zero address.");
        require(_exist(_tokenId),
                "`_tokenId` is not a valid NFT.");
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        address owner = ownerOf(_tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
                "Unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.");

        _tokenApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        _setApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal {
        _operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_exist(_tokenId),
                "`_tokenId` is not a valid NFT.");
        return _tokenApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }
    
    function _isApprovedForAll(address _owner, address _operator) internal view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function _transferable(address _spender, uint256 _tokenId) internal view returns (bool){
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        _clearApproval(_tokenId);
        _tokenOwner[_tokenId] = _to;
        _balance[_from] = _balance[_from].sub(1);
        _balance[_to] = _balance[_to].add(1);
        emit Transfer(_from, _to, _tokenId);
    }
  
    function _mint(address _to, uint256 _tokenId) internal {
        require(!_exist(_tokenId), "mint token already exists");
        _tokenOwner[_tokenId] = _to;
        _balance[_to] = _balance[_to].add(1);
        emit Transfer(address(0), _to, _tokenId);
    }
  
    function _burn(uint256 _tokenId) internal {
        require(_exist(_tokenId), "burn token does not already exists");
        address owner = ownerOf(_tokenId);
        _clearApproval(_tokenId);
        _tokenOwner[_tokenId] = address(0);
        _balance[owner] = _balance[owner].sub(1);
        emit Transfer(owner, address(0), _tokenId);
    }

    function _exist(uint256 _tokenId) internal view returns (bool) {
        address owner = _tokenOwner[_tokenId];
        return owner != address(0);
    }

    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) 
        internal
        returns (bool) 
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) internal {
        if (_tokenApproved[tokenId] != address(0)) {
            _tokenApproved[tokenId] = address(0);
        }
    }
}
