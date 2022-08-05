const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');
const {inputParam} = require('@polly-os/utils/js/PollyConfigurator.js')

// configs = {};
// configs.collection = require('../polly_configurators/Collection');
// configs.catalogue = require('../polly_configurators/Catalogue');
// configs.aux_handler = require('../polly_configurators/CollectionAux');
// configs.chains = require('../polly_configurators/Chains');

const TEST_CHAIN = 2;

/*********************
 * CHAINS
 */

describe("Chains.sol", async function(){

    const nullAddress = '0x'+'0'.repeat(40);

    let
    polly,
    Collection,
    collection,
    AuxHandler,
    aux_handler,
    Catalogue,
    catalogue,
    Chains,
    chains,
    moderation,
    owner,
    user1,
    user2,
    user3,
    minter1,
    minter2,
    minter3

    const MANAGER = '0x'+keccak256('MANAGER').toString('hex');

    it("init polly", async function(){

      [owner, user1, user2, user3] = await ethers.getSigners();

      // DEPLOY POLLY

      // const Polly = await ethers.getContractFactory("Polly");
      // polly = await Polly.deploy();
      // console.log('Polly deployed to -> ', polly.address.green);


      // FORKED POLLY
      polly = await hre.ethers.getContractAt('Polly', process.env.POLLY_ADDRESS, owner);
      console.log('Using forked Polly at -> ', polly.address.green);

    })


    it("deploys and is configurable", async function () {

        // Catalogue
        Catalogue = await ethers.getContractFactory("Catalogue");
        catalogue = await Catalogue.deploy();
        await catalogue.deployed();
        expect(catalogue.address).to.be.properAddress;

        // Add catalogue handler to Polly
        await polly.updateModule(catalogue.address);
        const catalogue_module = await polly.getModule('catalogue', 0);
        expect(catalogue_module.implementation).to.be.properAddress;



        // Collection
        Collection = await ethers.getContractFactory("Collection");
        collection = await Collection.deploy();
        await collection.deployed();
        expect(collection.address).to.be.properAddress;

        // Add collection to Polly
        await polly.updateModule(collection.address);
        const collection_module = await polly.getModule('collection', 0);
        expect(collection_module.implementation).to.be.properAddress;


        // Collection AuxHandler
        AuxHandler = await ethers.getContractFactory("CollectionAuxHandler");
        aux_handler = await AuxHandler.deploy();
        await aux_handler.deployed();
        expect(aux_handler.address).to.be.properAddress;

        // Add aux handler to Polly
        await polly.updateModule(aux_handler.address);
        const aux_handler_module = await polly.getModule('collection.aux_handler', 0);
        expect(aux_handler_module.implementation).to.be.properAddress;


        // Chains
        Chains = await ethers.getContractFactory("Chains");
        chains = await Chains.deploy();
        await chains.deployed();
        expect(chains.address).to.be.properAddress;


        // Add chains handler to Polly
        await polly.updateModule(chains.address);
        const chains_module = await polly.getModule('chains', 0);
        expect(chains_module.implementation).to.be.properAddress;




        /// RUN CONFIGURATOR

        const tx = await polly.runModuleConfigurator(
          'chains', // Name
          0, // Latest version
          [], // No params
          true // Store config in Polly
        );

        const receipt = await tx.wait();
        const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
        const arg = args[args.length-1];

        await expect(tx).to.emit(polly, 'moduleConfigured');

        catalogue = await Catalogue.attach(arg[0]._address);
        collection = await Collection.attach(arg[1]._address);
        aux_handler = await AuxHandler.attach(arg[2]._address)
        chains = await Chains.attach(arg[3]._address);


    });


    it("managers can init chains", async function(){

        moderation = true;

        // Init a chain
        await chains.initChain(
            'Derive', // Creator name
            user1.address, // First contributor
            user2.address, // Admin
            7, // Number of nodes
            10, // Units per node
            30, // Admin units
            ethers.utils.parseEther('0.01'), // Price per edition
            moderation ? true : false,
        ); // Wether to moderate submission before addition to the chain


        const chain = await chains.getChain(1);
        const edition = await collection.getEdition(chain.edition, true);

        // console.log(chain)
        // console.log(edition)

        expect(chain.id).to.equal(1);

    })

    it("lots of chains can be created", async function(){

        const testChains = [
            ['chain2', user3.address, user1.address, 7, 10, 10, 0, false],
            ['chain3', user3.address, user1.address, 3, 5, 25, ethers.utils.parseEther('1'), true],
            ['chain4', user3.address, user1.address, 10, 2, 2, ethers.utils.parseEther('12'), false],
        ]

        const max = 10;
        let i = 1;
        while(i < max){
            await chains.initChain(...testChains[Math.floor(Math.random()*testChains.length)]);
            // console.log(await collection.getEdition(i, true))
            i++;
        }

        expect(await chains.getChainCount()).to.equal(max);

    });

    it("contributor can update chain", async function(){

        // The node object we'll be passing into contract
        const node = [
        1, // Chain ID of the chain to add this to
        'First track', // Name of entry
        'Great first artist', // Creator of entry
        'https://link.to/file.mp3', // URL to the media file
        'f49481f2f1491116a9854751a5faac4e087f9dbe', // Checksum of media file
        user3.address // Next contributor
        ];


        // Check assertions
        await expect(chains.connect(user3).submitNode(node)).to.be.revertedWith('ONLY_CONTRIBUTOR');

        // Save a snapshot of the chains before launch
        const chainBefore = await chains.getChain(1);
        const edBefore = await collection.getEdition(chainBefore.edition, true);

        // Check before snapshot
        expect(chainBefore.contributor).to.equal(user1.address);
        expect(chainBefore.node).to.equal(0);

        // User1 submits a node
        await chains.connect(user1).submitNode(node);

        // Check if moderation is on
        if(chainBefore.moderation){
            const submission = await chains.connect(user2).getNodeSubmission(1);
            await expect(chains.connect(user3).approveNodeSubmission(1)).to.be.revertedWith('ONLY_ADMIN');
            await chains.connect(user2).approveNodeSubmission(1);
            // TODO: Better checking here
        }

        // Get chain and edition after submission
        const chainAfter = await chains.getChain(1);
        const edAfter = await collection.getEdition(chainAfter.edition, true);

        // Retrieve the first item of the chain edition from the catalogue
        const item = await catalogue.getItem(edAfter.items[0]);

        expect(item.name).to.equal(node[1]); // Item name must equal node.name
        expect(item.creator).to.equal(node[2]); // Item creator must equal node.creator
        expect(item.sources[0]).to.equal(node[3]); // Source #0 must equal node.source
        expect(item.checksum).to.equal(node[4]); // Item checksum must equal node.checksum
        expect(chainAfter.contributor).to.equal(user3.address); // Next contributor must be set correctly
        expect(chainAfter.node).to.equal(1); // Current node should be incremented by 1

    })


    it("chains can complete", async function(){

        // The node object we'll be passing into contract
        const node = [
            TEST_CHAIN, // Chain ID of the chain to add this to
            'Track', // Name of entry
            'Artist', // Creator of entry
            'https://link.to/file.mp3', // URL to the media file
            'f49481f2f1491116a9854751a5faac4e087f9dbe', // Checksum of media file
            user1.address // Next contributor
        ];
        // console.log(node)

        let currChain = await chains.getChain(node[0]);
        let current = 2;
        let current_user;

        while(currChain.node.toNumber() < currChain.nodes.toNumber()){

            current++;
            if(current > 3)
                current = 1;

            if(current == 1){
                current_user = user1;
                node[5] = user2.address;
            }
            else if(current == 2){
                current_user = user2;
                node[5] = user3.address;
            }
            else if(current == 3){
                current_user = user3;
                node[5] = user1.address;
            }

            // console.log(currChain.contributor, current_user.address);
            await chains.connect(current_user).submitNode(node);

            // Check if moderation is on
            if(currChain.moderation){
                const submission = await chains.connect(user1).getNodeSubmission(node[0]);
                await chains.connect(user1).approveNodeSubmission(node[0]);
            }

            currChain = await chains.getChain(node[0]);
            const ed = await collection.getEdition(currChain.edition, true);

            // console.log(currChain.node.toNumber(), currChain.nodes.toNumber(), ed.recipient, node[5]);

        }

        expect(currChain.node.toNumber()).to.equal(currChain.nodes);

    });

    it("chains are mintable", async function(){

        this.timeout(120000);

        const chainid = TEST_CHAIN;
        let ed = await collection.getEdition(chainid, true);
        // console.log(ed)

        let i = 0;
        while(i < ed.supply){
            await collection.mint(chainid, {value: ed.price});
            // console.log('mint', i+1)
            i++;
        }

    })


});
