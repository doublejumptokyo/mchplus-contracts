pragma solidity ^0.5.0;

import "../erc/ERC721.sol";
import "../roles/Operatable.sol";

contract ERC721TokenPausable is ERC721,Operatable {
    using Roles for Roles.Role;
    Roles.Role private tokenPauser;

    event TokenPauserAdded(address indexed account);
    event TokenPauserRemoved(address indexed account);

    event TokenPaused(uint256 indexed tokenId);
    event TokenUnpaused(uint256 indexed tokenId);

    mapping (uint256 => bool) private _tokenPaused;

    constructor() public {
        tokenPauser.add(msg.sender);
    }

    modifier onlyTokenPauser() {
        require(isTokenPauser(msg.sender), "Only token pauser can call this method");
        _;
    }

    modifier whenNotTokenPaused(uint256 _tokenId) {
        require(!isTokenPaused(_tokenId), "TokenPausable: paused");
        _;
    }

    modifier whenTokenPaused(uint256 _tokenId) {
        require(isTokenPaused(_tokenId), "TokenPausable: not paused");
        _;
    }

    function pauseToken(uint256 _tokenId) public onlyTokenPauser() {
        require(!isTokenPaused(_tokenId), "Token is already paused");
        _tokenPaused[_tokenId] = true;
        emit TokenPaused(_tokenId);
    }

    function unpauseToken(uint256 _tokenId) public onlyTokenPauser() {
        require(isTokenPaused(_tokenId), "Token is not paused");
        _tokenPaused[_tokenId] = false;
        emit TokenUnpaused(_tokenId);
    }

    function isTokenPaused(uint256 _tokenId) public view returns (bool) {
        return _tokenPaused[_tokenId];
    }

    function isTokenPauser(address account) public view returns (bool) {
        return tokenPauser.has(account);
    }

    function addTokenPauser(address account) public onlyOperator() {
        tokenPauser.add(account);
        emit TokenPauserAdded(account);
    }

    function removeTokenPauser(address account) public onlyOperator() {
        tokenPauser.remove(account);
        emit TokenPauserRemoved(account);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable
                            whenNotPaused() whenNotTokenPaused(_tokenId) {
        super.safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable
                            whenNotPaused() whenNotTokenPaused(_tokenId) {
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable
                            whenNotPaused() whenNotTokenPaused(_tokenId) {
        super.transferFrom(_from, _to, _tokenId);
    }
}
