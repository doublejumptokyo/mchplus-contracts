pragma solidity ^0.5.0;

import "../roles/Operatable.sol";
import "../erc/ERC721.sol";

contract ERC721Approvable is ERC721, Operatable {
    // Approvable list
    Roles.Role private approvableContracts;
    Roles.Role private preapprovedContracts;
    mapping (address => mapping (address => bool)) private _expresslyNotApprovalOperator;

    event UpdateApprovableContracts (address operator, bool approved);
    event UpdatePreapprovedContracts (address operator, bool approved);

    constructor() public {}

    // Approvable list
    function setApprovableContracts(address _operator, bool _approvable) public onlyOperator() {
        require(_operator.isContract(), "_operator must be contract");
        emit UpdateApprovableContracts(_operator, _approvable);
        if (_approvable) {
            approvableContracts.add(_operator);
        } else {
            require(!isPreApprovedContract(_operator), "_operator must not be preapproved");
            approvableContracts.remove(_operator);
        }
    }

    function isApprovableContract(address _operator) public view returns (bool) {
        return approvableContracts.has(_operator);
    }

    function setPreapprovedContracts(address _operator, bool _approval) public onlyOperator() {
        require(_operator.isContract(), "_operator must be contract");
        require(isApprovableContract(_operator), "_operator must not be approvable");
        emit UpdatePreapprovedContracts(_operator, _approval);
        if (_approval) {
            preapprovedContracts.add(_operator);
        } else {
            preapprovedContracts.remove(_operator);
        }
    }

    function isPreApprovedContract(address _operator) public view returns (bool) {
        return preapprovedContracts.has(_operator);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        if (_operator.isContract()) {
            require(isApprovableContract(_operator), "_operator must belong to approvable role");
            _expresslyNotApprovalOperator[msg.sender][_operator] = !_approved;
        }
        super.setApprovalForAll(_operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        if (_operator.isContract()) {
            if (!isApprovableContract(_operator)) {
                return false;
            }
            if (isPreApprovedContract(_operator)) {
                return !_expresslyNotApprovalOperator[_owner][_operator];
            }
        }
        return super.isApprovedForAll(_owner, _operator);
    }
}
