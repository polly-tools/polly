require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");
require("@polly-tools/hardhat-polly");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  polly: {
    fork: {
      localhost: process.env.POLLY_ADDRESS
    }
  },
  abiExporter: {
    runOnCompile: true,
    path: "./abi",
    only: ["RoyaltyInfo"],
    clear: true,
    flat: true,
  }
};
