pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IERC20.sol";

contract StakingEnv is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserAgent {
        uint256 amount;         // current staked LP
        uint256 lastUpdateAt;   // unix timestamp for last details update (when pointsDebt calculated)
        uint256 pointsDebt;     // total points collected before latest deposit
    }

    struct NFTItem {
        address contractAddress;
        uint256 id;             // NFT id
        uint256 remaining;      // NFTs remaining to farm
        uint256 price;          // points required to claim NFT
    }

    uint256 public emissionRate;
    IERC20 testCoin;

    NFTItem[] public nftItems;
    mapping(address => UserAgent) public userAgents;

    function StakingEnv(uint256 _emissionRate, IERC20 _testCoin){
        emissionRate = _emissionRate;
        testCoin = _testCoin;
    }

    function addNFT(
        address contractAddress,    // Only ERC-1155 NFT Supported!
        uint256 id,
        uint256 total,              // amount of NFTs deposited to farm (need to approve before)
        uint256 price
    ) external onlyOwner {
        IERC1155(contractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            total,
            ""
        );
        nftItems.push(NFTItem({
        contractAddress: contractAddress,
        id: id,
        remaining: total,
        price: price
        }));
    }

    function deposit(uint256 _amount) external {
        lpToken.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        UserAgent storage user = userInfo[msg.sender];

        // already deposited before
        if(user.amount != 0) {
            user.pointsDebt = pointsBalance(msg.sender);
        }
        user.amount = user.amount.add(_amount);
        user.lastUpdateAt = now;
    }

    function claim(uint256 _nftIndex, uint256 _quantity) public {
        NFTItem storage nft = nftItems[_nftIndex];
        require(nft.remaining > 0, "All NFTs farmed");
        require(pointsBalance(msg.sender) >= nft.price.mul(_quantity), "Insufficient Points");
        UserAgent storage user = userAgents[msg.sender];

        // deduct points
        user.pointsDebt = pointsBalance(msg.sender).sub(nft.price.mul(_quantity));
        user.lastUpdateAt = now;

        // transfer nft
        IERC1155(nft.contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            nft.id,
            _quantity,
            ""
        );

        nft.remaining = nft.remaining.sub(_quantity);
    }

    function claimMultiple(uint256[] calldata _nftIndex, uint256[] calldata _quantity) external {
        require(_nftIndex.length == _quantity.length, "Incorrect array length");
        for(uint64 i=0; i< _nftIndex.length; i++) {
            claim(_nftIndex[i], _quantity[i]);
        }
    }

    // claim random nft's from available balance
    function claimRandom() public {
        for(uint64 i; i < nftCount(); i++) {
            NFTItem storage nft = nftItems[i];
            uint256 userBalance = pointsBalance(msg.sender);
            uint256 maxQty = userBalance.div(nft.price);        // max quantity of nfts user can claim
            if(nft.remaining > 0 && maxQty > 0) {
                if(maxQty <= nft.remaining) {
                    claim(i, maxQty);
                } else {
                    claim(i, nft.remaining);
                }
            }
        }
    }

    function withdraw(uint256 _amount) public {
        UserAgent storage user = userAgents[msg.sender];
        require(user.amount >= _amount, "Insufficient staked");

        // update userInfo
        user.pointsDebt = pointsBalance(msg.sender);
        user.amount = user.amount.sub(_amount);
        user.lastUpdateAt = now;

        lpToken.safeTransfer(
            msg.sender,
            _amount
        );
    }

    function exit() external {
        claimRandom();
        withdraw(userAgents[msg.sender].amount);
    }

    function pointsBalance(address userAddress) public view returns (uint256) {
        UserAgent memory user = userAgents[userAddress];
        return user.pointsDebt.add(_unDebitedPoints(user));
    }

    function _unDebitedPoints(UserAgent memory user) internal view returns (uint256) {
        return now.sub(user.lastUpdateAt).mul(emissionRate).mul(user.amount);
    }

    function nftCount() public view returns (uint256) {
        return nftItems.length;
    }

    // required function to allow receiving ERC-1155
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    returns(bytes4)
    {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}
