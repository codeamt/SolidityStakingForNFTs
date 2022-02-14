# Solidity Staking for Non-Fungible Tokens (NFTs)

A simple staking environment; users stake erc-20 tokens to yield ERC-1155 tokens. This contract was developed and tested with HardHat.

## How the contract works: 

- User deposits NFTs to contract, worth x amount of "points" (ERC-20 "TestTokens").
- User can also increase point balance, by depositing/staking TestTokens
- If a User has enough points (meets a points threshold, they can use points to claim NFTs
- Points are accumulated at configurable emission rate 

## Key Features

- Applied use case of ERC-1155 Multi-token Standard 
- Supports staking for dedicated ERC-20 token (e.g., TestToken)
- Point emission rate proportional to staked TestTokens
- Yielding entire NFT collections or single collectibles
- Pause/resume functionality
- Supports full exit, withdrawing NFTs and TestTokens in a single transaction

## Contract Functions
0. The Constructor 
```
constructor(uint256 _emissionRate, IERC20 _testToken) public;
```

1. Depositing NFTs
```
function addNFT(
    address contractAddress, 
    uint256 id, 
    uint256 total, 
    ui external;nt256 price
) external;
```

2. Deposit TestTokens
```
function deposit(uint256 _amount) external;
```

3. Viewing Point Balance 
```
function pointsBalance(address userAddress) public view returns (uint256);
```

4. Claim specific NFTs for Points
```
function claim(uint256 _nftIndex, uint256 quantity) public;
```

5. Claim random NFTs for points 
```
function claimRandom() public; 
```

6. Withdraw TestTokens 
```
function withdraw(uint256 amount) public;
```

7. Make an Exit
```
function exit() external; 
```

## Local Development

#### Accessing the Code and Compiling Contact:

```
$ git clone https://github.com/codeamt/SolidityStakingForNFTs && cd SolidityStakingForNFTs
$ npm install 
$ npx hardhat compile
```

#### Running Tests:

```
$ npx hardhat test
```

#### Running example script utilizing 

```
$ npx hardhat node
$ node scripts/sample-script.js
```

