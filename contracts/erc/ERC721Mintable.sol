pragma solidity ^0.5.0;

import "./ERC721.sol";
import "../roles/Operatable.sol";

interface IERC721Mintable {
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    function exist(uint256 _tokenId) external view returns (bool);
    function mint(address _to, uint256 _tokenId) external;
    function isMinter(address account) external view returns (bool);
    function addMinter(address account) external;
    function removeMinter(address account) external;
}

contract ERC721Mintable is ERC721, IERC721Mintable, Operatable {
    using Roles for Roles.Role;
    Roles.Role private minters;

    constructor() public {
        addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "Must be minter");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyOperator() {
        minters.add(account);
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyOperator() {
        minters.remove(account);
        emit MinterRemoved(account);
    }
    
    function exist(uint256 tokenId) public view returns (bool) {
        return _exist(tokenId);
    }

    function mint(address to, uint256 tokenId) public onlyMinter() {
        _mint(to, tokenId);
    }
}