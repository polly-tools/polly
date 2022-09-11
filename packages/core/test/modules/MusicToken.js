const { expect } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {parseParam, param, Enums} = require('@polly-os/utils/js/Polly.js')

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

describe("MusicToken module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    mt,
    token,
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
      await hre.polly.addModule('MetaForIds');
      await hre.polly.addModule('Polly721');
      await hre.polly.addModule('Polly1155');
      await hre.polly.addModule('MusicToken', polly.address);

      // Init musictoken module
      // const mt_module_  = await polly.getModule('MusicToken', 1);
      // mt = await ethers.getContractAt('MusicToken', mt_module_.implementation);

      // Init token module

      const params = [
        param('Polly1155')
      ];

      let fee = await polly.getConfiguratorFee(owner.address, 'MusicToken', 1, params);
      fee = fee.add(await polly.fee(owner.address));

      [mt, config] = await hre.polly.configureModule('MusicToken', {
        for: owner.address,
        version: 1,
        params: params,
      }, {value: fee});

      token = await ethers.getContractAt('Polly1155', config.params[1]._address);

    })


    it("Create token", async function(){

      await token.createToken([
        ['title', param('My Song')],
        ['artist', param('My Artist')],
        ['isrc', param('DKU3-202200101')],
        ['originalReleaseDate', param('1970-01-01')],
        ['duration', param(420)],
        ['genre', param('World')],
        ['recordLabel', param('My Label')],
      ], [owner.address], [1])

      await token.createToken([
        ['title', param('My Song 2')],
        ['artist', param('My Artist 2')],
      ], [], [])

    })

    it("produces correct json", async function(){

      let json = await token.uri(1);
      // console.log(json);

      json = await token.uri(2);
      // console.log(json);

    })


})
