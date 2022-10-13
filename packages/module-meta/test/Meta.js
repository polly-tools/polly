const { expect, config } = require("chai");
const { ethers } = require("hardhat");

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

    it("Setup", async function(){
      [owner, user1, user2, user3] = await ethers.getSigners();
      polly = await hre.polly.deploy();
      await hre.polly.addModule('Json');
      await hre.polly.addModule('Meta');
    })

    it('Configure module', async function(){

        // Configure Meta
        const tx = await polly.configureModule(
          'Meta', // Name
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
        meta = await ethers.getContractAt('Meta', config[0].params[0]._address);

    });


    it('Accepts meta', async function(){

      await meta['setString(uint256,string,string)'](1, 'testkey1', 'testvalue1');
      await meta['setString(uint256,string,string)'](1, 'testkey2', 'testvalue2');
      await meta['setInt(uint256,string,int256)'](1, 'testkey3', -100);
      await meta['setUint(uint256,string,uint256)'](1, 'testkey3', 100);
      await meta['setBool(uint256,string,bool)'](1, 'testkey4', true);
      await meta['setAddress(uint256,string,address)'](1, 'testkey4', owner.address);

      const value = await meta.get(1, 'testkey1');
      expect (value._string).to.equal('testvalue1');

      const inject = await meta.getJSON(
        1,
        [
          {_key: 'testkey1', _type: Type.STRING, _inject: ''},
          {_key: 'testkey2', _type: Type.STRING, _inject: ''},
        ],
        Format.OBJECT
      );

      const result = await meta.getJSON(
      1,
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
