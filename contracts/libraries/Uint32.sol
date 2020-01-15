pragma solidity ^0.5.0;

library Uint32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(a >= b, "subtraction overflow");
        return a - b;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, "division by 0");
        return a / b;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, "modulo by 0");
        return a % b;
    }

}
