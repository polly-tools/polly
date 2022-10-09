// Test module
require('dotenv').config();
const path = require('path');
const { execSync } = require('child_process');
const { exit } = require('process');

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const argv = yargs(hideBin(process.argv)).argv
const {name} = argv
const safeName = name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
const modulePath = path.join(__dirname, '..', `packages/module-${safeName}`);

async function deployModule() {

  // Deploy module
  execSync(`npx hardhat polly:deploy-module`, { cwd: modulePath, stdio: 'inherit', env: process.env});

}

deployModule();
