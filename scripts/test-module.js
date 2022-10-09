// Test module
require('dotenv').config();
const path = require('path');
const { execSync } = require('child_process');

const split = process.argv[2].split('@');
const name = split[0].trim();
const version = split[1].trim() ? split[1].trim() : '1';
const safeName = name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
const modulePath = path.join(__dirname, '..', `packages/module-${safeName}`);

async function testModule(name) {
  execSync(`npx hardhat test test/${name}_v${version}.js`, { cwd: modulePath, stdio: 'inherit', env: process.env});
}

testModule(name);
