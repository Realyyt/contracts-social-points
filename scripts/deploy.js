const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Etherscan API Key:", process.env.ETHERSCAN_API_KEY ? "Present" : "Missing");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy PrizeStorage first
  const PrizeStorage = await ethers.getContractFactory("PrizeStorage");
  console.log("Deploying PrizeStorage...");
  const prizeStorage = await upgrades.deployProxy(PrizeStorage, [deployer.address], {
    initializer: "initialize",
  });
  await prizeStorage.waitForDeployment();
  console.log("PrizeStorage deployed to:", await prizeStorage.getAddress());

  // Deploy PrizeDistributor
  const PrizeDistributor = await ethers.getContractFactory("PrizeDistributor");
  console.log("Deploying PrizeDistributor...");
  const prizeDistributor = await upgrades.deployProxy(
    PrizeDistributor,
    [deployer.address, await prizeStorage.getAddress()],
    {
      initializer: "initialize",
    }
  );
  await prizeDistributor.waitForDeployment();
  console.log("PrizeDistributor deployed to:", await prizeDistributor.getAddress());

  // Deploy GameFactory
  const GameFactory = await ethers.getContractFactory("GameFactory");
  console.log("Deploying GameFactory...");
  const gameFactory = await upgrades.deployProxy(GameFactory, [], {
    initializer: "initialize",
  });
  await gameFactory.waitForDeployment();
  console.log("GameFactory deployed to:", await gameFactory.getAddress());

  // Wait for a few block confirmations
  const prizeStorageAddress = await prizeStorage.getAddress();
  const prizeDistributorAddress = await prizeDistributor.getAddress();
  const gameFactoryAddress = await gameFactory.getAddress();

  console.log("\nDeployment complete! Contract addresses:");
  console.log("PrizeStorage:", prizeStorageAddress);
  console.log("PrizeDistributor:", prizeDistributorAddress);
  console.log("GameFactory:", gameFactoryAddress);

  // Add after your existing deployment code
  console.log("\nVerifying contracts...");
  
  await hre.run("verify:verify", {
    address: prizeStorageAddress,
    constructorArguments: []
  });

  await hre.run("verify:verify", {
    address: prizeDistributorAddress,
    constructorArguments: []
  });

  await hre.run("verify:verify", {
    address: gameFactoryAddress,
    constructorArguments: []
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
