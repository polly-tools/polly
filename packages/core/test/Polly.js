const { expect } = require("chai");
const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const { colors } = require('colors');
const {inputParam} = require("@polly-os/utils/js/PollyConfigurator");

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

    // Read only
    const TestModule1 = await ethers.getContractFactory("TestModule1");
    contracts.testModule1 = await TestModule1.deploy();

    // Clonable
    const TestModule2 = await ethers.getContractFactory("TestModule2");
    contracts.testModule2 = await TestModule2.deploy();

    // Clonable with configurator
    const TestModule3 = await ethers.getContractFactory("TestModule3");
    contracts.testModule3 = await TestModule3.deploy();

    console.log(`   Polly -> `, contracts.polly.address.yellow);
    console.log(`   TestModule -> `, contracts.testModule1.address.yellow);
    console.log(`   TestModule2 -> `, contracts.testModule2.address.yellow);
    console.log(`   TestModule3 -> `, contracts.testModule3.address.yellow);

    users[1] = await contracts.polly.connect(wallet1);
    users[2] = await contracts.polly.connect(wallet2);
    users[3] = await contracts.polly.connect(wallet3);

    expect(contracts.polly.address).to.be.a.properAddress

  });

  describe("updateModule()", async function(){

    it("reverts on non-owner", async function(){
      await expect(users[1].updateModule(contracts.testModule2.address))
      .to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("allows owner to add modules", async function(){
      expect(contracts.polly.updateModule(contracts.testModule1.address))
      .to.emit(contracts.polly, 'moduleUpdated')
      expect(contracts.polly.updateModule(contracts.testModule2.address))
      .to.emit(contracts.polly, 'moduleUpdated')
      expect(contracts.polly.updateModule(contracts.testModule3.address))
      .to.emit(contracts.polly, 'moduleUpdated')
    });

  });


  describe("getModule()", async function(){

    it("returns valid modules", async function(){

      const tModule1 = await contracts.polly.getModule('TestModule1', 0);
      expect(tModule1.name).to.equal('TestModule1');
      expect(tModule1.version).to.equal(1);
      expect(tModule1.implementation).to.equal(contracts.testModule1.address);

      const tModule2 = await contracts.polly.getModule('TestModule2', 0);
      expect(tModule2.name).to.equal('TestModule2');
      expect(tModule2.version).to.equal(1);
      expect(tModule2.implementation).to.equal(contracts.testModule2.address);

      const tModule3 = await contracts.polly.getModule('TestModule3', 0);
      expect(tModule3.name).to.equal('TestModule3');
      expect(tModule3.version).to.equal(1);
      expect(tModule3.implementation).to.equal(contracts.testModule3.address);

    });

  });

  describe("getModules()", async function(){

    it("returns valid module list", async function(){

      const page1 = await contracts.polly.getModules(1, 1);
      const page2 = await contracts.polly.getModules(1, 2);
      const page3 = await contracts.polly.getModules(1, 3);

      expect(page1.length).to.equal(1);
      expect(page2.length).to.equal(1);
      expect(page3.length).to.equal(1);

    });

  });


  describe("Anyone can", async function(){

    it("create a configuration", async function(){

      await expect(contracts.polly.configureModule('TestModule3', 0, [], false))
      .to.emit(contracts.polly, 'moduleConfigured');

    })

    it("create a configuration and store it for the owner", async function(){

      await expect(contracts.polly.configureModule('TestModule3', 0, [], true))
      .to.emit(contracts.polly, 'moduleConfigured');

      const configs = await contracts.polly.getConfigsForAddress(owner.address, 5, 1);
      expect(configs[0].params[0].key).to.equal('Hello');
      expect(configs[0].params[0]._string).to.equal('World!');

    })

  });



  describe("No one can...", async function(){

    it("init a module", async function(){
      await expect(contracts.testModule2['init(address)'](users[3].address)).to.be.revertedWith('CAN_NOT_INIT');
    });

    it("use a non-existing module", async function(){
      await expect(users[2].cloneModule('fakeModule', 1)).to.be.revertedWith('INVALID_MODULE_OR_VERSION: fakeModule');
    });

  });


});
