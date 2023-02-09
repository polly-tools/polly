require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");
require("hardhat-gas-reporter");
require("@polly-tools/hardhat-polly");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  polly: {
    fork: {
      localhost: process.env.POLLY_ADDRESS
    }
  },
  gasReporter: {
    enabled: true,
    gasPrice: 25,
    currency: 'ETH',
    coinmarketcap: process.env.CMC_API_KEY
  },
  abiExporter: {
    runOnCompile: true,
    path: "./abi",
    only: ["TokenRegistry"],
    clear: true,
    flat: true,
  }
};
