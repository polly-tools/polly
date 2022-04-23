const hre = require("hardhat");
const networkName = hre.network.name;
require("colors");

async function main() {

  if(networkName !== 'localhost'){
    console.log(`NOT LOCALHOST! ${networkName.toUpperCase()} DETECTED`.bgRed)
    throw '';
  }

  console.log('DEPLOYING TO LOCALHOST'.bgGreen);

  await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x3827014f2236519f1101ae2e136985e0e603be79"]
  });

  await network.provider.send("hardhat_setBalance", [
      "0x3827014f2236519f1101ae2e136985e0e603be79",
      hre.ethers.utils.parseEther('1000').toHexString(),
  ]);

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
