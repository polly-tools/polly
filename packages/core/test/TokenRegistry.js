const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {inputParam} = require('@polly-os/utils/js/PollyConfigurator.js')


/*********************
 * CHAINS
 */

describe("TokenRegistry module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    TokenRegistry,
    token_registry,
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

        // TokenRegistry
        TokenRegistry = await ethers.getContractFactory("TokenRegistry");
        token_registry = await TokenRegistry.deploy();
        await token_registry.deployed();
        expect(token_registry.address).to.be.properAddress;


        // Add token_registry handler to Polly
        await polly.updateModule(token_registry.address);
        const token_registry_module = await polly.getModule('TokenRegistry', 0);
        expect(token_registry_module.implementation).to.be.properAddress;

    })

    it('Configure module', async function(){

        // Configure TokenRegistry
        const tx = await polly.configureModule(
          'TokenRegistry', // Name
          0, // Latest version
          [], // No params
          true // Store config in Polly
        );

        const receipt = await tx.wait();
        const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
        const arg = args[args.length-1];

        await expect(tx).to.emit(polly, 'moduleConfigured');

        const config = await polly.getConfigsForAddress(owner.address, 1, 1);

        expect(config[0].name).to.equal('TokenRegistry');
        token_registry = await TokenRegistry.attach(config[0].params[0]._address);

    });


    it('Allow manager to add providers', async function(){



    });

});

