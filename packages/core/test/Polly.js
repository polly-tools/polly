const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseParam, parseParams, Enums } = require("@polly-os/utils/js/Polly");

describe("Polly", function () {

  const contracts = {};
  const users = [];
  const nullAddress = '0x'.padEnd(42, '0');

  let owner;
  let wallet1;
  let wallet2;
  let wallet3;


  describe("Polly.sol", async function () {

    it("can deploy", async function(){

      [owner, wallet1, wallet2, wallet3] = await hre.ethers.getSigners();
      // console.log(`   owner -> `, owner.address.blue);
      // console.log(`   wallet1 -> `, wallet1.address.blue);
      // console.log(`   wallet2 -> `, wallet2.address.blue);
      // console.log(`   wallet3 -> `, wallet3.address.blue);
      // console.log('');

      delete hre.polly.fork;
      contracts.polly = await hre.polly.deploy();

      // Read only
      const TestReadOnly = await ethers.getContractFactory("TestReadOnly_v1");
      contracts.testReadOnly = await TestReadOnly.deploy();

      // Clonable
      const TestClone = await ethers.getContractFactory("TestClone_v1");
      contracts.testClone = await TestClone.deploy();

      // console.log(`   Polly -> `, contracts.polly.address.yellow);
      // console.log(`   TestModule -> `, contracts.testReadOnly.address.yellow);
      // console.log(`   TestClone -> `, contracts.testClone.address.yellow);

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



      });

      it("reverts on invalid modules", async function(){

        await expect(contracts.polly.getModule('TestReadOnly', 10))
        .to.be.revertedWith('INVALID_MODULE_OR_VERSION: TestReadOnly@10');
        await expect(contracts.polly.getModule('TestClone', 10))
        .to.be.revertedWith('INVALID_MODULE_OR_VERSION: TestClone@10');

      });

    });

    describe("getModules()", async function(){

      it("returns valid module list", async function(){

        const page1 = await contracts.polly.getModules(1, 1, false);
        const page2 = await contracts.polly.getModules(1, 2, false);
        const page3 = await contracts.polly.getModules(1, 3, false);

        const allASC = await contracts.polly.getModules(0, 0, true);
        const allDSC = await contracts.polly.getModules(0, 0, false);

        // console.log(allASC)
        // console.log(allDSC)

        expect(page1.length).to.equal(1);
        expect(page2.length).to.equal(1);
        expect(page3.length).to.equal(0);

        expect(allASC.length).to.equal(2);
        expect(allASC[0].name).to.equal('TestReadOnly');
        expect(allASC[1].name).to.equal('TestClone');

        expect(allDSC.length).to.equal(2);
        expect(allDSC[0].name).to.equal('TestClone');
        expect(allDSC[1].name).to.equal('TestReadOnly');

      });

    });


    describe("configureModule()", async function(){


      it("allows anyone to create a configuration", async function(){

        // Owner
        await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 0, parseParams([1000]), false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

        // User 2
        await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 0, parseParams([2000]), false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 0, [], false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 0, parseParams([2000]), false, ''))
        .to.emit(contracts.polly, 'moduleConfigured');

      })

      it("stores configurations correctly", async function(){

        await expect(contracts.polly.configureModule('TestClone', 0, [], true, 'My config1'))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 1, [], true, 'My config2'))
        .to.emit(contracts.polly, 'moduleConfigured');

        await expect(contracts.polly.configureModule('TestClone', 2, [], true, ''))
        .to.be.revertedWith('INVALID_MODULE_OR_VERSION: TestClone@2');

        const configs = await contracts.polly.getConfigsForAddress(owner.address, 10, 1, true);
        // console.log(configs)
        expect(configs.length).to.equal(2);
        expect(configs[0].params[0]._address).to.be.properAddress;

      })

    });

  })



  describe("PollyModule.sol", async function(){

    describe("init()", async function(){

      it('can init once', async function(){

        const [localClone, config] = await hre.polly.configureModule('TestClone', {
          version: 1
        });
        await expect(localClone.init(wallet1.address)).to.be.revertedWith('ALREADY_INITIALIZED');

      })




    })

  })





});
