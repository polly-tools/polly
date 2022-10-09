// Test module
require('dotenv').config();
const path = require('path');
const { execSync } = require('child_process');
const { exit } = require('process');

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const argv = yargs(hideBin(process.argv)).argv
const {modules, update, network} = argv

const module_objects = modules.split(',').map(module => {
  const split = module.split('@');
  return {
    name: split[0].trim(),
    at: split[1] ? split[1].trim() : 1
  }
});


async function deployModules() {

  // Deploy module
  for (const module of module_objects) {
    const safeName = module.name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
    const modulePath = path.join(__dirname, '..', `packages/module-${safeName}`);
    console.log(process.env.POLLY_ADDRESS)
    execSync(`npx hardhat polly:deploy-module --name ${module.name} --at ${module.at} --update ${update} --network ${network}`, { cwd: modulePath, stdio: 'inherit', env: process.env});
  }

}

deployModules();
