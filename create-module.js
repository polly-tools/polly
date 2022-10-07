const { execSync } = require('child_process');
const fs = require('fs');


const CamelCaseToHyphen = (str) => {
  return str.replace(/([a-z0-9]|(?=[A-Z]))([A-Z])/g, '$1-$2').toLowerCase().replace(/^-/, '');
};

const moduleName = process.argv[2];
const safeModuleName = CamelCaseToHyphen(moduleName);
const modulePath = `./packages/module-${safeModuleName}`;

async function create(){
  await fs.mkdirSync(modulePath);
  await fs.copyFileSync('./module-template/hardhat.config.js', `${modulePath}/hardhat.config.js`);
  await fs.copyFileSync('./module-template/package.json', `${modulePath}/package.json`);
  await fs.copyFileSync('./module-template/README.md', `${modulePath}/README.md`);

  // Replace {MODULE_NAME} in hardhat.config.js
  let data = fs.readFileSync(`${modulePath}/hardhat.config.js`, 'utf8');
  let result = data.replace(/{MODULE_NAME}/g, moduleName);
  result = data.replace(/{SAFE_MODULE_NAME}/g, safeModuleName);
  await fs.writeFileSync(`${modulePath}/hardhat.config.js`, result, 'utf8');

  // Replace {MODULE_NAME} in package.json
  data = fs.readFileSync(`${modulePath}/package.json`, 'utf8');
  result = data.replace(/{MODULE_NAME}/g, moduleName);
  result = data.replace(/{SAFE_MODULE_NAME}/g, safeModuleName);
  await fs.writeFileSync(`${modulePath}/package.json`, result, 'utf8');

  // Replace {MODULE_NAME} in README.md
  data = fs.readFileSync(`${modulePath}/README.md`, 'utf8');
  result = data.replace(/{MODULE_NAME}/g, moduleName);
  result = data.replace(/{SAFE_MODULE_NAME}/g, safeModuleName);
  await fs.writeFileSync(`${modulePath}/README.md`, result, 'utf8');

  await fs.mkdirSync(`${modulePath}/contracts`);
  await fs.writeFileSync(`${modulePath}/contracts/${moduleName}_v1.sol`, '');
  await fs.mkdirSync(`${modulePath}/test`);
  await fs.writeFileSync(`${modulePath}/test/${moduleName}_v1.js`, '');

}

create();
