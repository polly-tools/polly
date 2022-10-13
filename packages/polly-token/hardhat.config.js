require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");

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
    only: ["{MODULE_NAME}"],
    clear: true,
    flat: true,
  }
};
