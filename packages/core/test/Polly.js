const { expect } = require("chai");
const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const { colors } = require('colors');
const {inputParam} = require("@polly-os/utils/js/PollyConfigurator");
const { parseParam, Enums } = require("@polly-os/utils/js/Polly");

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
    const TestReadOnly = await ethers.getContractFactory("TestReadOnly");
    contracts.testReadOnly = await TestReadOnly.deploy();

    // Clonable
    const TestClone = await ethers.getContractFactory("TestClone");
    contracts.testClone = await TestClone.deploy();

    // Clonable
    const TestCloneKeystore = await ethers.getContractFactory("TestCloneKeystore");
    contracts.testCloneKeystore = await TestCloneKeystore.deploy();

    console.log(`   Polly -> `, contracts.polly.address.yellow);
    console.log(`   TestModule -> `, contracts.testReadOnly.address.yellow);
    console.log(`   TestClone -> `, contracts.testClone.address.yellow);
    console.log(`   TestCloneKeystore -> `, contracts.testCloneKeystore.address.yellow);

    users[1] = await contracts.polly.connect(wallet1);
    users[2] = await contracts.polly.connect(wallet2);
    users[3] = await contracts.polly.connect(wallet3);

    expect(contracts.polly.address).to.be.a.properAddress

  });

  describe("updateModule()", async function(){

    it("reverts on non-owner", async function(){
      await expect(users[1].updateModule(contracts.testClone.address))
      .to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("allows owner to add modules", async function(){
      expect(contracts.polly.updateModule(contracts.testReadOnly.address))
      .to.emit(contracts.polly, 'moduleUpdated')

      expect(contracts.polly.updateModule(contracts.testClone.address))
      .to.emit(contracts.polly, 'moduleUpdated')

      expect(contracts.polly.updateModule(contracts.testCloneKeystore.address))
      .to.emit(contracts.polly, 'moduleUpdated')
    });

  });


  describe("getModule()", async function(){

    it("returns valid modules", async function(){

      const tModule1 = await contracts.polly.getModule('TestReadOnly', 0);
      expect(tModule1.name).to.equal('TestReadOnly');
      expect(tModule1.version).to.equal(1);
      expect(tModule1.implementation).to.equal(contracts.testReadOnly.address);
      expect(tModule1.clone).to.equal(false);

      const tModule1_1 = await contracts.polly.getModule('TestReadOnly', 1);
      expect(tModule1_1.name).to.equal('TestReadOnly');
      expect(tModule1_1.version).to.equal(1);
      expect(tModule1_1.implementation).to.equal(contracts.testReadOnly.address);
      expect(tModule1_1.clone).to.equal(false);

      const tModule2 = await contracts.polly.getModule('TestClone', 0);
      expect(tModule2.name).to.equal('TestClone');
      expect(tModule2.version).to.equal(1);
      expect(tModule2.implementation).to.equal(contracts.testClone.address);
      expect(tModule2.clone).to.equal(true);

      const tModule2_1 = await contracts.polly.getModule('TestClone', 1);
      expect(tModule2_1.name).to.equal('TestClone');
      expect(tModule2_1.version).to.equal(1);
      expect(tModule2_1.implementation).to.equal(contracts.testClone.address);
      expect(tModule2_1.clone).to.equal(true);

      const tModule3 = await contracts.polly.getModule('TestCloneKeystore', 0);
      expect(tModule3.name).to.equal('TestCloneKeystore');
      expect(tModule3.version).to.equal(1);
      expect(tModule3.implementation).to.equal(contracts.testCloneKeystore.address);
      expect(tModule3.clone).to.equal(true);


      const tModule3_1 = await contracts.polly.getModule('TestCloneKeystore', 1);
      expect(tModule3_1.name).to.equal('TestCloneKeystore');
      expect(tModule3_1.version).to.equal(1);
      expect(tModule3_1.implementation).to.equal(contracts.testCloneKeystore.address);
      expect(tModule3_1.clone).to.equal(true);

    });

    it("reverts on invalid modules", async function(){

      await expect(contracts.polly.getModule('TestReadOnly', 10))
      .to.be.revertedWith('INVALID_MODULE_OR_VERSION');
      await expect(contracts.polly.getModule('TestClone', 10))
      .to.be.revertedWith('INVALID_MODULE_OR_VERSION');
      await expect(contracts.polly.getModule('TestCloneKeystore', 10))
      .to.be.revertedWith('INVALID_MODULE_OR_VERSION');

    });

  });

  describe("getModules()", async function(){

    it("returns valid module list", async function(){

      const page1 = await contracts.polly.getModules(1, 1, false);
      const page2 = await contracts.polly.getModules(1, 2, false);
      const page3 = await contracts.polly.getModules(1, 3, false);
      const page4 = await contracts.polly.getModules(1, 4, false);

      const allASC = await contracts.polly.getModules(0, 0, true);
      const allDSC = await contracts.polly.getModules(0, 0, false);

      // console.log(allASC)
      // console.log(allDSC)

      expect(page1.length).to.equal(1);
      expect(page2.length).to.equal(1);
      expect(page3.length).to.equal(1);
      expect(page4.length).to.equal(0);

      expect(allASC.length).to.equal(3);
      expect(allASC[0].name).to.equal('TestReadOnly');
      expect(allASC[1].name).to.equal('TestClone');
      expect(allASC[2].name).to.equal('TestCloneKeystore');

      expect(allDSC.length).to.equal(3);
      expect(allDSC[0].name).to.equal('TestCloneKeystore');
      expect(allDSC[1].name).to.equal('TestClone');
      expect(allDSC[2].name).to.equal('TestReadOnly');

    });

  });


  describe("configureModule()", async function(){


    it("allows anyone to create a configuration", async function(){

      // Owner
      await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 0, [parseParam(Enums.ParamType.UINT, 1000)], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

      // User 2
      await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 0, [parseParam(Enums.ParamType.UINT, 2000)], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 0, [parseParam(Enums.ParamType.UINT, 2000)], false, ''))
      .to.emit(contracts.polly, 'moduleConfigured');

    })

    it("stores configurations correctly", async function(){

      await expect(contracts.polly.configureModule('TestClone', 0, [], true, 'My config1'))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 1, [], true, 'My config2'))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestCloneKeystore', 1, [
        parseParam(Enums.ParamType.UINT, 1000),
      ], true, 'My config3'))
      .to.emit(contracts.polly, 'moduleConfigured');

      await expect(contracts.polly.configureModule('TestClone', 2, [], true, ''))
      .to.be.revertedWith('INVALID_MODULE_OR_VERSION');

      const configs = await contracts.polly.getConfigsForAddress(owner.address, 10, 1, true);
      // console.log(configs)
      expect(configs.length).to.equal(3);
      expect(configs[0].params[0]._address).to.be.properAddress;

    })

  });



  describe("No one can...", async function(){

    it("init a module", async function(){
      await expect(contracts.testClone['init(address,address)'](users[3].address, users[3].address)).to.be.revertedWith('CAN_NOT_INIT');
    });

    it("use a non-existing module", async function(){
      await expect(users[2].cloneModule('fakeModule', 1)).to.be.revertedWith('INVALID_MODULE_OR_VERSION: fakeModule');
    });

    it("use other peoples's modules", async function(){

      const configs = await contracts.polly.getConfigsForAddress(owner.address, 10, 1, true);
      const TestCloneKeystore = await ethers.getContractFactory("TestCloneKeystore");
      const testCloneKeystore = await TestCloneKeystore.attach(configs[2].params[0]._address);

      await testCloneKeystore.set(Enums.ParamType.STRING, 'test', parseParam(Enums.ParamType.STRING, 'should work'));
      const test = await testCloneKeystore.get('test');
      await expect(test._string).to.equal('should work');

      await expect(testCloneKeystore.connect(wallet2).set(Enums.ParamType.STRING, 'test', parseParam(Enums.ParamType.STRING, 'should fail'))).to.be.revertedWith('MISSING_ROLE');

    })

  });




});
