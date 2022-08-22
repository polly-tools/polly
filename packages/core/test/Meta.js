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
  INJECT: 3
}

/*********************
 * CHAINS
 */

describe("Meta module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    Meta,
    meta,
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
      console.log('Using forked Polly at -> ', polly.address.green);

    })


    it("Add module to Polly", async function () {

        // Meta
        Meta = await ethers.getContractFactory("Meta");
        meta = await Meta.deploy();
        await meta.deployed();
        expect(meta.address).to.be.properAddress;


        // Add meta handler to Polly
        await polly.updateModule(meta.address);
        const meta_module = await polly.getModule('Meta', 0);
        expect(meta_module.implementation).to.be.properAddress;

    })

    it('Configure module', async function(){

        // Configure Meta
        const tx = await polly.configureModule(
          'Meta', // Name
          0, // Latest version
          [], // No params
          true // Store config in Polly
        );

        const receipt = await tx.wait();
        const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
        const arg = args[args.length-1];

        await expect(tx).to.emit(polly, 'moduleConfigured');

        const config = await polly.getConfigsForAddress(owner.address, 1, 1, true);
        expect(config[0].params[0]._address).to.be.properAddress;
        meta = await Meta.attach(config[0].params[0]._address);

    });


    it('Accepts meta', async function(){

      await meta['setString(string,string,string)']('testID', 'testkey1', 'testvalue1');
      await meta['setString(string,string,string)']('testID', 'testkey2', 'testvalue2');
      await meta['setUint(string,string,uint256)']('testID', 'testkey3', 100);
      await meta['setBool(string,string,bool)']('testID', 'testkey4', true);

      const value = await meta['getString(string,string)']('testID', 'testkey1');
      expect (value).to.equal('testvalue1');

      const inject = await meta.getJSON(
        'testID',
        [
          {_key: 'testkey1', _type: Type.STRING, _inject: ''},
          {_key: 'testkey2', _type: Type.STRING, _inject: ''},
        ],
        Format.ARRAY
      );

      const json = await meta.getJSON(
      'testID',
      [
        {_key: 'testkey1', _type: Type.STRING, _inject: ''},
        {_key: 'testkey2', _type: Type.STRING, _inject: ''},
        {_key: 'testkey3', _type: Type.NUMBER, _inject: ''},
        {_key: 'testkey4', _type: Type.BOOL, _inject: ''},
        {_key: 'testkey5', _type: Type.INJECT, _inject: inject}
      ],
      Format.OBJECT
      );
      console.log(json)
      console.log(JSON.parse(json))
    })



});
