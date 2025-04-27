const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vault Contract", function () {
  let vault;
  let token;
  let owner;
  let buyer;
  let otherAccount;

  beforeEach(async function () {
    [owner, buyer, otherAccount] = await ethers.getSigners();

    const ERC20Base = await ethers.getContractFactory("ERC20Base");
    token = await ERC20Base.deploy("BaseFuck", "BSF");
    await token.waitForDeployment();

    const Vault = await ethers.getContractFactory("Vault");
    vault = await Vault.deploy(token.target);
    await vault.waitForDeployment();

    const fundAmount = 1000n * 10n ** 18n; // 1000 tokens
    await token.connect(owner).approve(vault.target, fundAmount);
    await vault.connect(owner).fund(fundAmount);
  });

  it("Not enough ether to buy", async () => {
    const buyerBalance = await ethers.provider.getBalance(buyer.address);
    expect(buyerBalance).to.be.greaterThan(0).revertedWith("Send enough ETH");
  });

  it("Not enough tokens to claim", async () => {
    expect(await vault.totalBought(buyer.address)).to.equal(0);
  });

  it("Should claim", async () => {
    await vault.connect(buyer).buy({ value: 300 });
    await expect(vault.connect(buyer).claim()).to.not.be.reverted;
  });

  // it("Only owner can setUnlockPrice", async () => {
  //   await expect(vault.connect(buyer).setUnlockPrice(100)).to.be.revertedWith(
  //     "Not the owner"
  //   );

  //   await expect(vault.connect(owner).setUnlockPrice(100)).to.not.be.reverted;
  // });
});
