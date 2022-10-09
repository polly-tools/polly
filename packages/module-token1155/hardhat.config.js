require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");
require("@polly-os/hardhat-polly");

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
    only: ["Token1155"],
    clear: true,
    rename: (name, contract) => name.replace(/contracts\/[\d\w_-]+_v(\d+).sol/, "v$1/" + contract),
  }
};
