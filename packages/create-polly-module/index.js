const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const { exit } = require('process');


const CamelCaseToHyphen = (str) => {
  return str.replace(/([a-z0-9]|(?=[A-Z]))([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
};
const templateDir = path.resolve(__dirname, 'module-template');
const moduleName = process.argv[2];
const safeModuleName = CamelCaseToHyphen(moduleName);
const modulePath = `./module-${safeModuleName}`;

async function create(){

  let data, result;

  await fs.mkdirSync(modulePath);
  await fs.copyFileSync(`${templateDir}/hardhat.config.js`, `${modulePath}/hardhat.config.js`);
  await fs.copyFileSync(`${templateDir}/package.json`, `${modulePath}/package.json`);
  await fs.copyFileSync(`${templateDir}/README.md`, `${modulePath}/README.md`);
  await fs.copyFileSync(`${templateDir}/.gitignore`, `${modulePath}/.gitignore`);

  // Replace module name placeholders in hardhat.config.js
  data = fs.readFileSync(`${modulePath}/hardhat.config.js`, 'utf8');
  result = await data.replaceAll(/\{MODULE_NAME\}/gm, moduleName).replaceAll(/\{SAFE_MODULE_NAME\}/gm, safeModuleName);
  await fs.writeFileSync(`${modulePath}/hardhat.config.js`, result, 'utf8');

  // Replace module name placeholders in package.json
  data = fs.readFileSync(`${modulePath}/package.json`, 'utf8');
  result = await data.replaceAll(/\{MODULE_NAME\}/gm, moduleName).replaceAll(/\{SAFE_MODULE_NAME\}/gm, safeModuleName);
  await fs.writeFileSync(`${modulePath}/package.json`, result, 'utf8');

  // Replace module name placeholders in README.md
  data = fs.readFileSync(`${modulePath}/README.md`, 'utf8');
  result = await data.replaceAll(/\{MODULE_NAME\}/gm, moduleName).replaceAll(/\{SAFE_MODULE_NAME\}/gm, safeModuleName);
  await fs.writeFileSync(`${modulePath}/README.md`, result, 'utf8');

  await fs.mkdirSync(`${modulePath}/contracts`);
  await fs.writeFileSync(`${modulePath}/contracts/${moduleName}_v1.sol`, '');
  await fs.mkdirSync(`${modulePath}/test`);
  await fs.writeFileSync(`${modulePath}/test/${moduleName}_v1.js`, '');

}

create();
