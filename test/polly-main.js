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

    console.log(`   Polly -> `, contracts.polly.address.yellow);
    console.log(`   TestModule -> `, contracts.testModule.address.yellow);

    users[1] = await contracts.polly.connect(wallet1);
    users[2] = await contracts.polly.connect(wallet2);
    users[3] = await contracts.polly.connect(wallet3);

    expect(contracts.polly.address).to.be.a.properAddress

  });

  describe("updateModule()", async function(){

    it("reverts on non-owner", async function(){

      expect(users[1].updateModule('testModule', contracts.testModule.address))
      .to.be.reverted;

    });

    it("allows owner to add module", async function(){
      expect(contracts.polly.updateModule('testModule', contracts.testModule.address))
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


      const configs = await users[1].getConfigsForOwner(wallet1.address);
      const config = await users[1].getConfig(configs[0]);
      console.log(config)

      // expect(tModule.name).to.equal('testModule');
      // expect(tModule.version).to.equal(1);
      // expect(tModule.implementation).to.equal(contracts.testModule.address);

    });

  });


});
