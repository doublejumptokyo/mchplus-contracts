pragma solidity ^0.5.0;

import "../erc/ERC721.sol";
import "../interfaces/IERC721Metadata.sol";
import "../roles/Operatable.sol";
import "../libraries/String.sol";
import "../libraries/Uint256.sol";

contract ERC721Metadata is IERC721Metadata, ERC721, Operatable {
    using Uint256 for uint256;
    using String for string;

    event UpdateTokenURIPrefix(
        string tokenUriPrefix
    );

    // Metadata
    string private __name;
    string private __symbol;
    string private __tokenUriPrefix;

    constructor(string memory _name,
                string memory _symbol,
                string memory _tokenUriPrefix) public {
        // ERC721Metadata
        __name = _name;
        __symbol = _symbol;
        setTokenURIPrefix(_tokenUriPrefix);
    }

    function setTokenURIPrefix(string memory _tokenUriPrefix) public onlyOperator() {
        __tokenUriPrefix = _tokenUriPrefix;
        emit UpdateTokenURIPrefix(_tokenUriPrefix);
    }

    function name() public view returns (string memory) {
        return __name;
    }

    function symbol() public view returns (string memory) {
        return __symbol;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return __tokenUriPrefix.concat(_tokenId.toString());
    }
}
