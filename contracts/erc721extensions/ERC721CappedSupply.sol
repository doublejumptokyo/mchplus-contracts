pragma solidity ^0.5.0;

import "../erc/ERC721Mintable.sol";
import "../libraries/Uint256.sol";
import "../libraries/Uint32.sol";

interface IERC721CappedSupply /* IERC721Mintable, IERC721 */ {
    event SetUnitCap(uint32 _assetType, uint32 _unitCap);
    event SetTypeCap(uint256 _typeCap);
    function totalSupply() external view returns (uint256);
    function getTypeOffset() external view returns (uint256);
    function getTypeCap() external view returns (uint256);
    function setTypeCap(uint32 _newTypeCap) external;
    function getTypeCount() external view returns (uint256);
    function existingType(uint32 _assetType) external view returns (bool);
    function getUnitCap(uint32 _assetType) external view returns (uint32);
    function setUnitCap(uint32 _assetType, uint32 _newUnitCap) external;
    function mint(address _to, uint256 _tokenId) external;
}

/// @title ERC-721 Capped Supply
/// @author double jump.tokyo inc.
/// @dev see https://medium.com/@makzent/the-2x2-matrix-for-blockchain-game-ecosystems-2645be502704
contract ERC721CappedSupply is IERC721CappedSupply, ERC721Mintable {
    using Uint256 for uint256;
    using Uint32 for uint32;

    uint32 private assetTypeOffset;
    mapping(uint32 => uint32) private unitCap;
    mapping(uint32 => uint32) private unitCount;
    mapping(uint32 => bool) private unitCapIsSet;
    uint256 private assetTypeCap = 2**256-1;
    uint256 private assetTypeCount = 0;
    uint256 private totalCount = 0;

    constructor(uint32 _assetTypeOffset) public {
        setTypeOffset(_assetTypeOffset);
    }

    function isValidOffset(uint32 _offset) private pure returns (bool) {
        for (uint32 i = _offset; i > 0; i = i.div(10)) {
            if (i == 10) {
                return true;
            }
            if (i.mod(10) != 0) {
                return false;
            }
        }
        return false;
    }

    function totalSupply() public view returns (uint256) {
        return totalCount;
    }

    function setTypeOffset(uint32 _assetTypeOffset) private {
        require(isValidOffset(_assetTypeOffset),  "Offset is invalid");
        assetTypeCap = assetTypeCap / _assetTypeOffset;
        assetTypeOffset = _assetTypeOffset;
    }

    function getTypeOffset() public view returns (uint256) {
        return assetTypeOffset;
    }

    function setTypeCap(uint32 _newTypeCap) public onlyMinter() {
        require(_newTypeCap < assetTypeCap, "New type cap cannot be less than existing type cap");
        require(_newTypeCap >= assetTypeCount, "New type cap must be more than current type count");
        assetTypeCap = _newTypeCap;
        emit SetTypeCap(_newTypeCap);
    }

    function getTypeCap() public view returns (uint256) {
        return assetTypeCap;
    }

    function getTypeCount() public view returns (uint256) {
        return assetTypeCount;
    }

    function existingType(uint32 _assetType) public view returns (bool) {
        return unitCapIsSet[_assetType];
    }

    function setUnitCap(uint32 _assetType, uint32 _newUnitCap) public onlyMinter() {
        require(_assetType != 0, "Asset Type must not be 0");
        require(_newUnitCap < assetTypeOffset, "New unit cap must be less than asset type offset");

        if (!existingType(_assetType)) {
            unitCapIsSet[_assetType] = true;
            assetTypeCount = assetTypeCount.add(1);
            require(assetTypeCount <= assetTypeCap, "Asset type cap is exceeded");
        } else {
            require(_newUnitCap < getUnitCap(_assetType), "New unit cap must be less than previous unit cap");
            require(_newUnitCap >= getUnitCount(_assetType), "New unit cap must be more than current unit count");
        }

        unitCap[_assetType] = _newUnitCap;
        emit SetUnitCap(_assetType, _newUnitCap);
    }

    function getUnitCap(uint32 _assetType) public view returns (uint32) {
        require(existingType(_assetType), "Asset type does not exist");
        return unitCap[_assetType];
    }

    function getUnitCount(uint32 _assetType) public view returns (uint32) {
        return unitCount[_assetType];
    }

    function mint(address _to, uint256 _tokenId) public onlyMinter() {
        require(_tokenId.mod(assetTypeOffset) != 0, "Index must not be 0");
        uint32 assetType = uint32(_tokenId.div(assetTypeOffset));
        unitCount[assetType] = unitCount[assetType].add(1);
        totalCount = totalCount.add(1);
        require(unitCount[assetType] <= getUnitCap(assetType), "Asset unit cap is exceed");
        super.mint(_to, _tokenId);
    }
}
