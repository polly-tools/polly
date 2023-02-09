// Test module
require('dotenv').config();
const path = require('path');
const { execSync } = require('child_process');

// const name = process.argv[2]
// const safeName = name.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
// const modulePath = path.join(__dirname, '..', `packages/module-${safeName}`);

async function run(name) {

  // Get module dirs
  const moduleDirs = execSync(`ls packages`).toString().split('\n').filter((dir) => dir.startsWith('module-'));
  const moduleNames = moduleDirs.map((dir) => dir.replace('module-', ''));
  const modulePaths = moduleDirs.map((dir) => path.join(__dirname, '..', `packages/${dir}`));

  // console.log(moduleDirs)
  // console.log(moduleNames)
  // console.log(modulePaths)

  const modules = moduleNames.map((name, i) => {
    return {name, path: modulePaths[i]};
  });

  // Compile modules
  for (const module of modules) {
    execSync(`hardhat compile`, { cwd: module.path, stdio: 'inherit', env: process.env});
  }

}

run();
