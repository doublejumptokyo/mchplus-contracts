pragma solidity ^0.5.0;

import "mchplus-contracts/roles/Roles.sol";
import "mchplus-contracts/roles/OperatorRole.sol";

contract MinterRole is OperatorRole {
    using Address for address;
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() public {}

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

}
