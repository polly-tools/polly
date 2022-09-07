const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {inputParam} = require('@polly-os/utils/js/PollyConfigurator.js')

const Format = {
  KEY_VALUE: 0,
  VALUE: 1,
  ARRAY: 2,
  OBJECT: 3
}

const Type = {
  STRING: 0,
  BOOL: 1,
  NUMBER: 2,
  ARRAY: 3,
  OBJECT: 4
}

/*********************
 * CHAINS
 */

describe("Hello module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    hello,
    json,
    owner,
    user1,
    user2,
    user3,
    minter1,
    minter2,
    minter3

    it("Use forked Polly", async function(){

      [owner, user1, user2, user3] = await ethers.getSigners();

      // DEPLOY POLLY
      const Polly = await ethers.getContractFactory("Polly");
      polly = await Polly.deploy();
      console.log('Polly deployed to -> ', polly.address.green);


      // FORKED POLLY
      // polly = await hre.ethers.getContractAt('Polly', process.env.POLLY_ADDRESS, owner);
      // console.log('Using forked Polly at -> ', polly.address.green);

    })


    it("Add Hello module to Polly", async function () {

        // Hello
        const Hello = await ethers.getContractFactory("Hello");
        hello = await Hello.deploy();
        await hello.deployed();
        expect(hello.address).to.be.properAddress;


        // Add hello handler to Polly
        await polly.updateModule(hello.address);
        const hello_module = await polly.getModule("Hello", 1);
        expect(hello_module.implementation).to.be.properAddress;

    })

    it("Add JSON module to Polly", async function () {
      // JSON
      const JSON = await ethers.getContractFactory("Json");
      json = await JSON.deploy();
      await json.deployed();
      expect(json.address).to.be.properAddress;


      // Add json handler to Polly
      await polly.updateModule(json.address);
      const json_module = await polly.getModule("Json", 1);
      expect(json_module.implementation).to.be.properAddress;

    })

    it('Configure module', async function(){

        // Configure Hello
        const tx = await polly.configureModule(
          'Hello', // Name
          0, // Latest version
          [], // No params
          true, // Store config in Polly
          '' // No config name
        );

        const receipt = await tx.wait();
        const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
        const arg = args[args.length-1];

        await expect(tx).to.emit(polly, 'moduleConfigured');

        const config = await polly.getConfigsForAddress(owner.address, 1, 1, false);
        expect(config[0].params[0]._address).to.be.properAddress;
        const Hello = await ethers.getContractFactory('Hello');
        hello = await Hello.attach(config[0].params[0]._address);

    });



});
