// Test module
require('dotenv').config();
const path = require('path');
const { execSync } = require('child_process');

const name = process.argv[2]
const safeName = name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
const modulePath = path.join(__dirname, '..', `packages/module-${safeName}`);

async function testModule(name) {
  execSync(`npx hardhat test test/${name}.js`, { cwd: modulePath, stdio: 'inherit', env: process.env});
}

testModule(name);
