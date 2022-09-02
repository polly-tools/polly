const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {inputParam} = require('@polly-os/utils/js/PollyConfigurator.js')


/*********************
 * CHAINS
 */

describe("Hello module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    Hello,
    hello,
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

      // const Polly = await ethers.getContractFactory("Polly");
      // polly = await Polly.deploy();
      // console.log('Polly deployed to -> ', polly.address.green);


      // FORKED POLLY
      polly = await hre.ethers.getContractAt('Polly', process.env.POLLY_ADDRESS, owner);
      // console.log('Using forked Polly at -> ', polly.address.green);

    })


    it("Add module to Polly", async function () {

        // Hello
        Hello = await ethers.getContractFactory("Hello");
        hello = await Hello.deploy();
        await hello.deployed();
        expect(hello.address).to.be.properAddress;


        // Add hello handler to Polly
        await polly.updateModule(hello.address);
        const hello_module = await polly.getModule('Hello', 0);
        expect(hello_module.implementation).to.be.properAddress;

    })

    it('Configure module', async function(){

        // Configure Hello
        const tx = await polly.configureModule(
          'Hello', // Name
          0, // Latest version
          [], // No params
          true // Store config in Polly
        );

        const receipt = await tx.wait();
        const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
        const arg = args[args.length-1];

        await expect(tx).to.emit(polly, 'moduleConfigured');

        const config = await polly.getConfigsForAddress(owner.address, 1, 1);

        expect(config[0].name).to.equal('Hello');
        hello = await Hello.attach(config[0].params[0]._address);

    });


    it("Say hello", async function(){

      expect(await hello.sayHello()).to.equal('Hello World!');
      await hello.setString('to', 'Polly');
      expect(await hello.sayHello()).to.equal('Hello Polly!');

    })


});
