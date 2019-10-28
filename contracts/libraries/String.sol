pragma solidity ^0.5.0;

library String {

    function concat(string memory _a, string memory _b) internal pure returns (string memory) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        bytes memory ret = new bytes(a.length + b.length);
        uint256 idx = 0;

        uint256 i;
        for (i = 0; i < a.length; i++) {
            ret[idx] = a[i];
            idx++;
        }

        for (i = 0; i < b.length; i++) {
            ret[idx] = b[i];
            idx++;
        }

        return string(ret);
    }
}
