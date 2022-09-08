const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {parseParam, Enums} = require('@polly-os/utils/js/Polly');

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

describe("Nft module", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    nft,
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
      await hre.polly.addModule('Nft');

      nft = await hre.polly.configureModule('Nft', {
        params: [
          parseParam(Enums.ParamType.STRING, 'Test NFT'),
          parseParam(Enums.ParamType.STRING, 'TNFT'),
          parseParam(Enums.ParamType.BOOL, true),
        ]
      })

      expect(await nft.name()).to.equal('Test NFT');
      expect(await nft.symbol()).to.equal('TNFT');

    })


    // describe("Regular NFT", async function(){

    //   it("returns correct name and symbol", async function(){
    //     expect(await nft.name()).to.equal('Test NFT');
    //     expect(await nft.symbol()).to.equal('TNFT');
    //   })


    // })



});
