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

    const TestModule1 = await ethers.getContractFactory("TestModule1");
    contracts.testModule1 = await TestModule1.deploy();

    const TestModule2 = await ethers.getContractFactory("TestModule2");
    contracts.testModule2 = await TestModule2.deploy();

    console.log(`   Polly -> `, contracts.polly.address.yellow);
    console.log(`   TestModule -> `, contracts.testModule1.address.yellow);
    console.log(`   TestModule2 -> `, contracts.testModule2.address.yellow);

    users[1] = await contracts.polly.connect(wallet1);
    users[2] = await contracts.polly.connect(wallet2);
    users[3] = await contracts.polly.connect(wallet3);

    expect(contracts.polly.address).to.be.a.properAddress

  });

  describe("updateModule()", async function(){

    it("reverts on non-owner", async function(){
      await expect(users[1].updateModule(contracts.testModule1.address))
      .to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("allows owner to add module", async function(){
      expect(contracts.polly.updateModule(contracts.testModule1.address))
      .to.emit(contracts.polly, 'moduleUpdated')
      expect(contracts.polly.updateModule(contracts.testModule2.address))
      .to.emit(contracts.polly, 'moduleUpdated')
    });

  });


  describe("getModule()", async function(){

    it("returns valid module", async function(){

      const tModule = await contracts.polly.getModule('TestModule1', 0);

      expect(tModule.name).to.equal('TestModule1');
      expect(tModule.version).to.equal(1);
      expect(tModule.implementation).to.equal(contracts.testModule1.address);

    });

  });

  describe("getModules()", async function(){

    it("returns valid module list", async function(){

      const page1 = await contracts.polly.getModules(1, 1);
      const page2 = await contracts.polly.getModules(1, 2);

      expect(page1.length).to.equal(1);
      expect(page2.length).to.equal(1);

    });

  });


  describe("No one can...", async function(){

    it("init a module", async function(){
      await expect(contracts.testModule2['init(address)'](users[3].address)).to.be.revertedWith('CAN_NOT_INIT');
    });

    it("use a non-existing module", async function(){
      await expect(users[2].cloneModule('fakeModule', 1)).to.be.revertedWith('MODULE_DOES_NOT_EXIST: fakeModule');
    });

  });


});
