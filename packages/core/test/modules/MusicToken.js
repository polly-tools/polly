const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {parseParam, Enums} = require('@polly-os/utils/js/Polly.js')

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
    p1155,
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
      await hre.polly.addModule('MetaForIds');
      // await hre.polly.addModule('Polly721');
      // await hre.polly.addModule('Polly1155');
      await hre.polly.addModule('MusicToken');

      p1155 = await hre.polly.configureModule('MusicToken', {
        params: [
          parseParam(Enums.ParamType.ADDRESS, '0x0000000000000000000000000000000000000000'), // Pass an aux
        ]
      })

    })


})
