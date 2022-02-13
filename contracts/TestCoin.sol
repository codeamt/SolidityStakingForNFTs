pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TestCoin is ERC20 {
    function TestCoin(address _initReceiver) public ERC20("TEST", "TEST"){
        _mint(_initReceiver, 100000000 * (10 ** uint256(decimals()))); // 100M
    }
}

