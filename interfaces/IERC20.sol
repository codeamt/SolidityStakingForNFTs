pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable){
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; //https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address user) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address delegate) external view returns(uint256);
    function approve(address delegate, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed delegate, uint256 amount);
}
