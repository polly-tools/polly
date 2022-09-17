const { expect } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {parseParam, param, Enums} = require('@polly-os/utils/js/Polly.js')


function base64DataUrlToJson(base64) {
  const data = base64.split(',')[1];
  const buff = Buffer.from(data, 'base64')
  const text = buff.toString('ascii')
  return JSON.parse(text)
}

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
    p1155,
    owner,
    user1,
    user2,
    user3

    it("Setup", async function(){

      [owner, user1, user2, user3] = await ethers.getSigners();

      polly = await hre.polly.deploy();
      await hre.polly.addModule('Json');
      await hre.polly.addModule('MetaForIds');
      await hre.polly.addModule('Polly721');
      await hre.polly.addModule('Polly1155');
      await hre.polly.addModule('MusicToken', polly.address);

      // Init Polly1155 module
      const params = [
        param('Polly1155')
      ];

      let fee = await polly.getConfiguratorFee(owner.address, 'MusicToken', 1, params);
      fee = fee.add(await polly.fee(owner.address, fee));

      [mt, config] = await hre.polly.configureModule('MusicToken', {
        version: 1,
        params: params,
      }, {value: fee});

      p1155 = await ethers.getContractAt('Polly1155', config.params[1]._address);

    })


    it("Create p1155", async function(){

      await p1155.createToken([
        ['title', param('My Song')],
        ['artist', param('My Artist')],
        ['isrc', param('DKU3-202200101')],
        ['losslessAudio', param('https://myserver.com/audio.wav')],
        ['animation_url', param('https://myserver.com/audio.mp3')]
      ], [owner.address], [1])

      await p1155.createToken([
        ['title', param('My Song 2')],
        ['artist', param('My Artist 2')],
      ], [], [])

      await expect(p1155.createToken([], [], [])).to.be.revertedWith('EMPTY_META');

    })

    it("Produce valid JSON", async function(){

      let json = await p1155.uri(1);
      json = base64DataUrlToJson(json);
      expect(json.title).to.equal('My Song');
      expect(json.artist).to.equal('My Artist');
      expect(json.isrc).to.equal('DKU3-202200101');
      expect(json.losslessAudio).to.equal('https://myserver.com/audio.wav');
      expect(json.animation_url).to.equal('https://myserver.com/audio.mp3');

      json = await p1155.uri(2);
      json = base64DataUrlToJson(json);
      expect(json.title).to.equal('My Song 2');
      expect(json.artist).to.equal('My Artist 2');

    })




})
