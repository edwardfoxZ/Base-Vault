const { ethers } = require("hardhat");

async function main() {
  const Erc20 = await ethers.getContractFactory("ERC20Base");
  console.log("Deploying Vault...");
  const erc20 = await Erc20.deploy();

  await erc20.waitForDeployment();
  console.log("Vault deployed to:", erc20.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
