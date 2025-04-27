require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      // chainId: "1337",
      accounts: [
        "0x38ab439c4c473992182668fbd98db476854e8cc7e24d3407fa2ef3d6e69abee2",
        "0xafc7f393070468d36851afbc39764dfed93c54f4747fc3b7dbeb9d28519ebc41",
        "0x1960ad10035edfb21b60d0f26541c4e844d213b00af16809a482a14a0197c3ec",
      ],
      gas: 200000,
    },
  },
};
