pragma solidity ^0.5.0;

import "./Roles.sol";

contract Withdrawable {
    using Roles for Roles.Role;

    event WithdrawerAdded(address indexed account);
    event WithdrawerRemoved(address indexed account);

    Roles.Role private withdrawers;

    constructor() public {
        withdrawers.add(msg.sender);
    }

    modifier onlyWithdrawer() {
        require(isWithdrawer(msg.sender), "Must be withdrawer");
        _;
    }

    function isWithdrawer(address account) public view returns (bool) {
        return withdrawers.has(account);
    }

    function addWithdrawer(address account) public onlyWithdrawer() {
        withdrawers.add(account);
        emit WithdrawerAdded(account);
    }

    function removeWithdrawer(address account) public onlyWithdrawer() {
        withdrawers.remove(account);
        emit WithdrawerRemoved(account);
    }

    function withdrawEther() public onlyWithdrawer() {
        msg.sender.transfer(address(this).balance);
    }

}
