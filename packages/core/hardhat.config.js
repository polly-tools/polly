require("dotenv").config({path: '.env'});
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-abi-exporter');
require("hardhat-gas-reporter");
require('solidity-coverage');
require("@polly-os/hardhat-polly");
require("./tasks.js");

const accounts = require('./hhaccounts.js');
accounts[0] = {privateKey: process.env.DEPLOYER_KEY, balance: '10000000000000000000000'};
const accounts_keys = accounts.map(account => account.privateKey)
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    },
  },
  polly: {
    verbose: true,
    fork: {
      // hardhat: process.env.POLLY_ADDRESS
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  gasReporter: {
    enabled: true,
    gasPrice: 25,
    currency: 'ETH',
    coinmarketcap: process.env.CMC_API_KEY
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  abiExporter: {
    path: './abi',
    runOnCompile: true,
    except: ['@openzeppelin', 'TestModule'],
    flat: true
  },
  networks: {
    hardhat: {
      accounts: accounts,
      forking: {
        blockNumber: 7523569,
        url: process.env.GOERLI_RPC_URL
      },
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      accounts: accounts_keys,
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: accounts_keys,
    },
    localhost: {
      gas: 10000000,
      url: process.env.LOCALHOST_RPC_URL,
      accounts: accounts_keys,
    }
  }
};
