const { task } = require("hardhat/config");
const { types } = require("hardhat/config")

const module_scripts = require('./module-scripts.js');

require("colors");

task("polly:deploy", "Deploys the Polly contract", async (taskArgs, hre) => {

  await hre.run('compile');
  console.log(`Deploying Polly to network ${hre.network.name}`);

  const Polly = await hre.ethers.getContractFactory("Polly");
  const polly = await Polly.deploy();
  await polly.deployed();

  console.log("Polly deployed to:", polly.address.green.bold);

});


task('polly:deploy-module', 'Deploy a module implementation', async ({name, update}) => {

  await hre.run('compile');
  console.log(`Deploying module ${name} to network ${hre.network.name}`);

  const Module = await hre.ethers.getContractFactory(name);
  let moduleAddress;
  if(module_scripts[name] && typeof module_scripts[name].deploy == 'function'){
    moduleAddress = await module_scripts[name].deploy(Module);
  }
  else{
    const moduleDeploy = await Module.deploy();
    await moduleDeploy.deployed();
    moduleAddress = moduleDeploy.address;
  }
  console.log(`${name} deployed to:`, moduleAddress.green.bold);

  if(update !== 'undefined')
    await hre.run('polly:update-module', {implementation: moduleAddress});

})
.addParam("name", "The module contract name")
.addOptionalParam("update", "Update module after deployment", false, types.boolean)


task('polly:update-module', 'Update a module in Polly', async ({implementation}) => {

  console.log(`Updating module on network ${hre.network.name}`);
  const [owner] = await ethers.getSigners();

  const polly = await hre.ethers.getContractAt('Polly', process.env.POLLY_ADDRESS, owner);
  const tx = await polly.updateModule(implementation);
  const receipt = await tx.wait();

  const events = receipt.events.filter(e => e.event === 'moduleUpdated');
  const [indexedname, name, version, address] = events[events.length-1].args;
  console.log(`Updated module ${name} to version ${version.toString()}`);

})
.addParam("implementation", "The module contract name")

