pragma solidity ^0.5.0;

import "../roles/Operatable.sol";
import "../erc/ERC721Holder.sol";

interface SupportedIERC721 {
    // Standard
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    
    // Extra
    function exist(uint256 _tokenId) external view returns (bool);
    function mint(address _to, uint256 _tokenId) external;
}

contract ERC721Helper is Operatable, ERC721Holder {

    constructor() public {}

    function balanceOf(address _target, address _owner) public view returns (uint256) {
        return SupportedIERC721(_target).balanceOf(_owner);
    }
    
    function ownerOf(address _target, uint256 _tokenId) public view returns (address) {
        return SupportedIERC721(_target).ownerOf(_tokenId);
    }

    function safeTransferFrom(
        address _target, 
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    )
        public
        payable
        onlyOperator()
    {
        return SupportedIERC721(_target).safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(address _target, address _from, address _to, uint256 _tokenId) public payable onlyOperator() {
        return SupportedIERC721(_target).safeTransferFrom(_from, _to, _tokenId);
    }
    
    function bulkSafeTransferFrom(
        address[] calldata _targets, 
        address[] calldata _froms,
        address[] calldata _tos,
        uint256[] calldata _tokenIds
    )
        external
        onlyOperator()
    {
        require(_tokenIds.length == _targets.length && _tokenIds.length == _froms.length && _tokenIds.length == _tos.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            safeTransferFrom(_targets[i], _froms[i], _tos[i], _tokenIds[i]);
        }
    }

    function transferFrom(address _target, address _from, address _to, uint256 _tokenId) public payable onlyOperator() {
        return SupportedIERC721(_target).transferFrom(_from, _to, _tokenId);
    }

    function bulktransferFrom(
        address[] calldata _targets, 
        address[] calldata _froms,
        address[] calldata _tos,
        uint256[] calldata _tokenIds
    )
        external
        onlyOperator()
    {
        require(_tokenIds.length == _targets.length && _tokenIds.length == _froms.length && _tokenIds.length == _tos.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            transferFrom(_targets[i], _froms[i], _tos[i], _tokenIds[i]);
        }
    }

    function approve(address _target, address _approved, uint256 _tokenId) public payable onlyOperator() {
        return SupportedIERC721(_target).approve(_approved, _tokenId);
    }

    function setApprovalForAll(address _target, address _operator, bool _approved) public onlyOperator() {
        return SupportedIERC721(_target).setApprovalForAll(_operator, _approved);
    }

    function getApproved(address _target, uint256 _tokenId) public view returns (address) {
        return SupportedIERC721(_target).getApproved(_tokenId);
    }

    function isApprovedForAll(address _target, address _owner, address _operator) public view returns (bool) {
        return SupportedIERC721(_target).isApprovedForAll(_owner, _operator);
    }
    
    // Extra
    function exist(address _target, uint256 _tokenId) public view returns (bool) {
        return SupportedIERC721(_target).exist(_tokenId);
    }

    function mint(address _target, address _to, uint256 _tokenId) public onlyOperator() {
        return SupportedIERC721(_target).mint(_to, _tokenId);
    }

    function bulkMint(address[] calldata _targets, address[] calldata _owners, uint256[] calldata _tokenIds) external onlyOperator() {
        require(_tokenIds.length == _targets.length && _tokenIds.length == _owners.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            mint(_targets[i], _owners[i], _tokenIds[i]);
        }
    }
  
    function kill() external onlyOperator() {
        selfdestruct(msg.sender);
    }
}