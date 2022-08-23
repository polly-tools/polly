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

describe("Meta module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    meta,
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

      // const Polly = await ethers.getContractFactory("Polly");
      // polly = await Polly.deploy();
      // console.log('Polly deployed to -> ', polly.address.green);


      // FORKED POLLY
      polly = await hre.ethers.getContractAt('Polly', process.env.POLLY_ADDRESS, owner);
      console.log('Using forked Polly at -> ', polly.address.green);

    })


    it("Add Meta module to Polly", async function () {

        // Meta
        const Meta = await ethers.getContractFactory("Meta");
        meta = await Meta.deploy();
        await meta.deployed();
        expect(meta.address).to.be.properAddress;


        // Add meta handler to Polly
        await polly.updateModule(meta.address);
        const meta_module = await polly.getModule('Meta', 0);
        expect(meta_module.implementation).to.be.properAddress;

    })

    it("Add JSON module to Polly", async function () {
      // JSON
      const JSON = await ethers.getContractFactory("JSON");
      json = await JSON.deploy();
      await json.deployed();
      expect(json.address).to.be.properAddress;


      // Add json handler to Polly
      await polly.updateModule(json.address);
      const json_module = await polly.getModule('JSON', 0);
      expect(json_module.implementation).to.be.properAddress;

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
        const Meta = await ethers.getContractFactory('Meta');
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
        Format.OBJECT
      );

      const result = await meta.getJSON(
      'testID',
      [
        {_key: 'testkey1', _type: Type.STRING, _inject: ''},
        {_key: 'testkey2', _type: Type.STRING, _inject: ''},
        {_key: 'testkey3', _type: Type.NUMBER, _inject: ''},
        {_key: 'testkey4', _type: Type.BOOL, _inject: ''},
        {_key: 'testkey5', _type: Type.OBJECT, _inject: inject}
      ],
      Format.OBJECT
      );

      const __json = JSON.parse(result);

      expect(__json.testkey1).to.equal('testvalue1');
      expect(__json.testkey2).to.equal('testvalue2');
      expect(__json.testkey3).to.equal(100);
      expect(__json.testkey4).to.equal(true);
      expect(__json.testkey5.testkey1).to.equal('testvalue1');
      expect(__json.testkey5.testkey2).to.equal('testvalue2');

    })



});
