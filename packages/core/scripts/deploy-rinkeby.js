const hre = require("hardhat");
const networkName = hre.network.name;
require("colors");

async function main() {

  if(networkName !== 'rinkeby'){
    console.log(`NOT RINKEBY! ${networkName.toUpperCase()} DETECTED`.bgRed)
    throw '';
  }

  console.log('DEPLOYING TO RINKEBY'.bgGreen);

  const Polly = await hre.ethers.getContractFactory("Polly");
  const polly = await Polly.deploy();
  await polly.deployed();

  console.log("Polly deployed to:", polly.address.green.bold);

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
