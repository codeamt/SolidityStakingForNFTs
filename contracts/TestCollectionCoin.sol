pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TestCollectionCoin is ERC1155("someBaseURI"){
    function TestCollectionCoin() public{
        _mint(msg.sender, 0, 100, "");
    }
}
