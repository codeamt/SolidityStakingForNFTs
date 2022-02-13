const { expect } = require("chai");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const {BN} = require("@openzeppelin/test-helpers");

describe("StakingEnv", function() {
  it("Should allow owners to list ERC-1155 NFT'", async function() {
    const [owner] = await ethers.getSigners();

    const NFTCollection = await hre.ethers.getContractFactory("TestCollectionCoin");
    const nftCollection = await NFTCollection.deploy();
    await nftCollection.deployed();

    const TestCoin = await hre.ethers.getContractFactory("TestCoin");
    const testCoin = await TestCoin.deploy(owner);
    await testCoin.deployed();


    const StakingEnv = await hre.ethers.getContractFactory("StakingEnv");
    const stakingEnv = await StakingEnv.deploy(new BN("1"), testCoin.address);
    await stakingEnv.deployed();


    nftCollection.setApprovalForAll(stakingEnv.address, true, {from: owner});
    const iniNFTCount = await stakingEnv.nftCount();
    stakingEnv.addNFT(
        nftCollection.address,
        "0",
        "10",
        "500",
        {from: owner}
    )

    const finalNFTCount = await stakingEnv.nftCount()
    expect(finalNFTCount).to.be.bignumber.gt(iniNFTCount);
  });

  it('allow user to stake TestCoins', async () => {
    const [owner, addr1] = await ethers.getSigners();
    const TestCoin2 = await hre.ethers.getContractFactory("TestCoin");
    const testCoin = await TestCoin2.deploy(owner);
    await testCoin.deployed();

    const StakingEnv = await hre.ethers.getContractFactory("StakingEnv");
    const stakingEnv = await StakingEnv.deploy(new BN("1"), testCoin.address);
    await stakingEnv.deployed();

    await testCoin.approve(stakingEnv.address, "1000000", {from: addr1})
    const coinBal = await testCoin.balanceOf(stakingEnv.address)
    await stakingEnv.deposit("1", {from: addr1})
    const finalCoinBal = await testCoin.balanceOf(stakingEnv.address)
    expect(finalCoinBal).to.be.bignumber.gt(coinBal)
  });

  it('should allow user to claim NFT reward', async () => {
    const [owner, addr1] = await ethers.getSigners();

    const TestCoin3 = await hre.ethers.getContractFactory("TestCoin");
    const testCoin = await TestCoin3.deploy(owner);
    await testCoin.deployed();

    const NFTCollection2 = await hre.ethers.getContractFactory("TestCollectionCoin");
    const nftCollection = await NFTCollection2.deploy();
    await nftCollection.deployed();

    const StakingEnv = await hre.ethers.getContractFactory("StakingEnv");
    const stakingEnv = await StakingEnv.deploy(new BN("1"), testCoin.address);
    await stakingEnv.deployed();

    const iniNFTBal = await nftCollection.balanceOf(addr1, "0")
    await stakingEnv.claim("0", "1", {from: addr1})
    const finalNFTBal = await nftCollection.balanceOf(addr1, "0")
    expect(finalNFTBal).to.be.bignumber.gt(iniNFTBal)
  });

  it('should allow user to unstake lp tokens', async () => {
    const [owner, addr1] = await ethers.getSigners();

    const TestCoin4 = await hre.ethers.getContractFactory("TestCoin");
    const testCoin = await TestCoin4.deploy(owner);
    await testCoin.deployed();

    const NFTCollection3 = await hre.ethers.getContractFactory("TestCollectionCoin");
    const nftCollection = await NFTCollection3.deploy();
    await nftCollection.deployed();

    const StakingEnv = await hre.ethers.getContractFactory("StakingEnv");
    const stakingEnv = await StakingEnv.deploy(new BN("1"), testCoin.address);
    await stakingEnv.deployed();


    const initCoinBal = await testCoin.balanceOf(addr1)
    const stakedBal = (await stakingEnv.userInfo(addr1)).amount
    await stakingEnv.withdraw(stakedBal, {from: addr1})
    const finalCoinBal = await testCoin.balanceOf(addr1)
    expect(finalCoinBal).to.be.bignumber.gt(initCoinBal)
  })
});


