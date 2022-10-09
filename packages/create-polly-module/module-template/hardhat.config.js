require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");
require("hardhat-gas-reporter");
require("@polly-os/hardhat-polly");

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
    only: ["{MODULE_NAME}"],
    clear: true,
    rename: (name, contract) => name.replace(/contracts\/[\d\w_-]+_v(\d+).sol/, "v$1/" + contract),
  }
};
