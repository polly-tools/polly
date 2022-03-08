const { expect } = require("chai");
const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const { colors } = require('colors');

describe("Polly", function () {

  const contracts = {};
  const users = [];
  const nullAddress = '0x'.padEnd(42, '0');

  let owner;
  let wallet1;
  let wallet2;
  let wallet3;

  it("can deploy", async function(){

    [owner, wallet1, wallet2, wallet3] = await hre.ethers.getSigners();
    console.log(`   owner -> `, owner.address.blue);
    console.log(`   wallet1 -> `, wallet1.address.blue);
    console.log(`   wallet2 -> `, wallet2.address.blue);
    console.log(`   wallet3 -> `, wallet3.address.blue);
    console.log('');

    const Polly = await ethers.getContractFactory("Polly");
    contracts.polly = await Polly.deploy();

    const TestModule = await ethers.getContractFactory("TestModule");
    contracts.testModule = await TestModule.deploy();

    const TestModule2 = await ethers.getContractFactory("TestModule2");
    contracts.testModule2 = await TestModule2.deploy();

    console.log(`   Polly -> `, contracts.polly.address.yellow);
    console.log(`   TestModule -> `, contracts.testModule.address.yellow);
    console.log(`   TestModule2 -> `, contracts.testModule2.address.yellow);

    users[1] = await contracts.polly.connect(wallet1);
    users[2] = await contracts.polly.connect(wallet2);
    users[3] = await contracts.polly.connect(wallet3);

    expect(contracts.polly.address).to.be.a.properAddress

  });

  describe("updateModule()", async function(){

    it("reverts on non-owner", async function(){
      await expect(users[1].updateModule('testModule', contracts.testModule.address))
      .to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("allows owner to add module", async function(){
      expect(contracts.polly.updateModule('testModule', contracts.testModule.address))
      .to.emit(contracts.polly, 'moduleUpdated')
      expect(contracts.polly.updateModule('testModule2', contracts.testModule2.address))
      .to.emit(contracts.polly, 'moduleUpdated')
    });

  });


  describe("getModule()", async function(){

    it("returns valid module", async function(){

      const tModule = await contracts.polly.getModule('testModule', 0);

      expect(tModule.name).to.equal('testModule');
      expect(tModule.version).to.equal(1);
      expect(tModule.implementation).to.equal(contracts.testModule.address);

    });

  });


  describe("createConfig()", async function(){

    it("allows anyone to create a config", async function(){

      await users[1].createConfig('test config', [
        ['testModule', 1, nullAddress]
      ]);

      const configs = await users[1].getConfigsForOwner(wallet1.address, 0, 0);
      const config = await users[1].getConfig(configs[0]);
      const module = config.modules[0];

      await users[3].createConfig('config1', []);
      await users[3].createConfig('config2', []);
      await users[3].createConfig('config3', []);
      await users[3].createConfig('config4', []);
      await users[3].createConfig('config5', []);

      expect(module.name).to.equal('testModule');
      expect(module.version).to.equal(1);

    });

    it("allows config owner to attach new module", async function(){

      const configs = await users[1].getConfigsForOwner(wallet1.address, 0, 0);
      const config_id = configs[0];

      await expect(users[2].useModule(config_id, ['testModule2', 1, nullAddress])).to.be.revertedWith('NOT_CONFIG_OWNER');
      expect(await users[1].useModule(config_id, ['testModule2', 1, nullAddress])).to.emit(contracts.polly, 'configUpdated')
      const config = await users[1].getConfig(config_id);

      expect(await users[1].useModule(config_id, config.modules[1])).to.emit(contracts.polly, 'configUpdated')

    })


  });

  describe("getConfigsForOwner", async function(){

    it("pulls correct configs", async function(){

      const configs1 = await users[1].getConfigsForOwner(wallet1.address, 0, 0)
      const configs3 = await users[3].getConfigsForOwner(wallet3.address, 0, 0)

      expect(configs1.length).to.equal(1);
      expect(configs3.length).to.equal(5);

      const configs3page1 = await users[3].getConfigsForOwner(wallet3.address, 3, 1);
      const configs3page2 = await users[3].getConfigsForOwner(wallet3.address, 3, 2);

      expect(configs3page1.length).to.equal(3);
      expect(configs3page2[configs3page1.length-1]).to.equal(0);

    });

  });

  describe("transferConfig()", async function(){

    it("allows config owner to transfer config", async function(){

      const configs1 = await users[1].getConfigsForOwner(wallet1.address, 0, 0);
      const configs2 = await users[1].getConfigsForOwner(wallet2.address, 0, 0);
      const config_id = configs1[0];

      await users[1].transferConfig(configs1[0], wallet2.address);

      const configs1after = await users[1].getConfigsForOwner(wallet1.address, 0, 0);
      const configs2after = await users[2].getConfigsForOwner(wallet2.address, 0, 0);

      await expect(users[3].transferConfig(config_id, wallet1.address)).to.be.revertedWith('NOT_CONFIG_OWNER');

      expect(configs1.length -1).to.equal(configs1after.length);
      expect(await users[1].isConfigOwner(config_id, wallet1.address)).is.false;
      expect(configs2.length +1).to.equal(configs2after.length);
      expect(await users[2].isConfigOwner(config_id, wallet2.address)).is.true;

    });

  });

  describe("No one can...", async function(){

    it("init a module", async function(){
      await expect(contracts.testModule2['init(address)'](users[3].address)).to.be.revertedWith('CAN_NOT_INIT');
    });

    it("use a non-existing module", async function(){

      const configs = await users[3].getConfigsForOwner(wallet2.address, 0, 0);
      const config_id = configs[0];

      await expect(users[2].useModule(config_id, ['fakeModule', 1, nullAddress])).to.be.revertedWith('MODULE_DOES_NOT_EXIST: fakeModule');
      await expect(users[2].useModules(config_id, [
        ['testModule', 1, nullAddress],
        ['fakeModule2', 1, nullAddress]
      ])).to.be.revertedWith('MODULE_DOES_NOT_EXIST: fakeModule2');

    });

  });


});
