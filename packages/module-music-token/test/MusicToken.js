const { expect } = require("chai");
const { ethers } = require("hardhat");
const {parseParams, parseParam, Enums} = require('@polly-tools/core/utils/Polly.js')


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
    p721,
    owner,
    user1,
    user2,
    user3

    it("Setup", async function(){

      [owner, user1, user2, user3] = await ethers.getSigners();

      polly = await hre.polly.deploy();
      await hre.polly.addModule('Json');
      await hre.polly.addModule('Meta');
      await hre.polly.addModule('TokenUtils');
      await hre.polly.addModule('Token721');
      await hre.polly.addModule('Token1155');
      await hre.polly.addModule('RoyaltyInfo');
      await hre.polly.addModule('MusicToken', polly.address);

      // Init Token1155 module
      const params = parseParams([
        'My great music album',
        'Token1155'
      ])

      let fee = await polly.getConfiguratorFee(owner.address, 'MusicToken', 1, params);
      fee = fee.add(await polly.fee(owner.address, fee));

      [mt, config] = await hre.polly.configureModule('MusicToken', {
        version: 1,
        params: params,
      }, {value: fee});

      p1155 = await ethers.getContractAt('Token1155', config.params[0]._address);

    })

    describe("Token1155", async function(){

      it("Create tokens", async function(){

        const prev_block_num = await ethers.provider.getBlockNumber();
        const prev_block = await ethers.provider.getBlock(prev_block_num);
        const min_time = prev_block.timestamp+(60*60*24);
        const max_time = min_time+(60*60*24*5);

        // console.log(min_time, max_time);

        await p1155.createToken([
          ['title', parseParam('My Song')],
          ['artist', parseParam('My Artist')],
          ['isrc', parseParam('DKU3-202200101')],
          ['losslessAudio', parseParam('https://myserver.com/audio.wav')],
          ['animation_url', parseParam('https://myserver.com/audio.mp3')],
          ['royalty_base', parseParam(300)],
          ['royalty_recipient', parseParam(user1.address)],
          ['min_time', parseParam(min_time)],
          ['max_time', parseParam(max_time)],
        ], [], [])

        await p1155.createToken([
          ['title', parseParam('My Song 2')],
          ['artist', parseParam('My Artist 2')],
          ['royalty_base', parseParam(250)],
          ['royalty_recipient', parseParam(user1.address)],
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

      it("Signals royalty", async function(){
        const {receiver_, amount_} = await p1155.royaltyInfo(2, ethers.utils.parseEther('1'));
        expect(receiver_).to.equal(user1.address);
        expect(amount_).to.equal(ethers.utils.parseEther('0.025'));
      })

      describe("mint()", async function(){

        it("allows anyone to mint", async function(){

            await expect(p1155.mint(1, 1)).to.be.revertedWith("MIN_TIME_NOT_REACHED")

            await network.provider.send("evm_increaseTime", [60*60*25]);
            await network.provider.send("evm_mine")

            await p1155.mint(1, 1);
            await p1155.mint(2, 100);

            expect(await p1155.balanceOf(owner.address, 1)).to.equal(1);
            expect(await p1155.balanceOf(owner.address, 2)).to.equal(100);

            await network.provider.send("evm_increaseTime", [60*60*24*5]);
            await network.provider.send("evm_mine")

            await expect(p1155.mint(1, 1)).to.be.revertedWith("MAX_TIME_REACHED")


        })

      });

    })






})
