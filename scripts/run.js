const hre = require("hardhat");

const { BN } = require("@openzeppelin/test-helpers");

async function main() {
    const [owner] = await hre.ethers.getSigners();

    const ExampleNFTCollection = await hre.ethers.getContractFactory("TestCollectionCoin");
    const nftCollection = await ExampleNFTCollection.deploy();
    await nftCollection.deployed();

    const TestCoin = await hre.ethers.getContractFactory("TestCoin");
    const testCoin = await TestCoin.deploy(owner.address);
    await testCoin.deployed();


    const StakingEnv = await hre.ethers.getContractFactory("StakingEnv");
    const stakingEnv = await StakingEnv.deploy(new BN("1"), testCoin.address);
    await stakingEnv.deployed();

    console.log("StakingEnv deployed to:", stakingEnv.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });