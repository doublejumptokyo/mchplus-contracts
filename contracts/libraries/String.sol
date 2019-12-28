pragma solidity ^0.5.0;

library String {

    function compare(string memory _a, string memory _b) public pure returns (bool) {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
    }

    function cut(string memory _s, uint256 _from, uint256 _range) public pure returns (string memory) {
        bytes memory s = bytes(_s);
        require(s.length >= _from + _range, "_s length must be longer than _from + _range");
        bytes memory ret = new bytes(_range);

        for (uint256 i = 0; i < _range; i++) {
            ret[i] = s[_from+i];
        }
        return string(ret);
    }

    function concat(string memory _a, string memory _b) internal pure returns (string memory) {
        return string(abi.encodePacked(_a, _b));
    }
}
