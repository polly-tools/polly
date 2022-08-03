const { expect, config } = require("chai");
const { ethers } = require("hardhat");
const keccak256 = require('keccak256')
const colors = require('colors');

catalogueConfig = require('../polly_configurators/Catalogue');

describe('Catalogue.sol', async function(){

    let catalogue, owner, user1, user2, user3;

    const item1 = [
        'Item no 1', 'Creator 1', 'ChecksumOfItem1', ["https://link.to/item1"]
    ];

    const item2 = [
        'Item no 2', 'Creator 2', 'ChecksumOfItem2', ["https://link.to/item2"]
    ];

    
    it("deploys", async function () {  

        [owner, user1, user2, user3] = await ethers.getSigners();
    
        const Catalogue = await ethers.getContractFactory("Catalogue");
        catalogue = await Catalogue.deploy();
        await catalogue.deployed();
        
        expect(catalogue.address).to.be.properAddress;
        
    });


    it("only manager can create items", async function(){
        await expect(catalogue.createItem(item1)).to.emit(catalogue, 'itemCreated').withArgs(1, owner.address);
        await expect(catalogue.createItem(item2)).to.emit(catalogue, 'itemCreated').withArgs(2, owner.address);
        await expect(catalogue.connect(user2).createItem(item1)).to.be.revertedWith("AccessControl: ");
        await expect(catalogue.connect(user3).createItem(item2)).to.be.revertedWith("AccessControl: ");
    });

    
    it("items are saved correctly", async function(){

        const savedItem1 = await catalogue.getItem(1);
        expect(savedItem1.name).to.equal(item1[0]);
        expect(savedItem1.creator).to.equal(item1[1]);
        expect(savedItem1.checksum).to.equal(item1[2]);
        expect(savedItem1.sources[0]).to.equal(item1[3][0]);

        const savedItem2 = await catalogue.getItem(2);
        expect(savedItem2.name).to.equal(item2[0]);
        expect(savedItem2.creator).to.equal(item2[1]);
        expect(savedItem2.checksum).to.equal(item2[2]);
        expect(savedItem2.sources[0]).to.equal(item2[3][0]);

    })


    describe("items", async function(){

        it("can be updated", async function(){

            const newItem1 = ['new name 1', 'new creator 1', 'newchecksum1'];
            const newItem2 = ['new name 2', 'new creator 2', 'newchecksum2'];

            await catalogue.updateItemName(1, newItem1[0]);
            await catalogue.updateItemCreator(1, newItem1[1]);
            await catalogue.updateItemChecksum(1, newItem1[2]);
            await catalogue.updateItem(2, newItem2[0], newItem2[1], newItem2[2]);

            const item1 = await catalogue.getItem(1);
            const item2 = await catalogue.getItem(2);


            expect(item1.name).to.equal(newItem1[0])
            expect(item1.creator).to.equal(newItem1[1])
            expect(item1.checksum).to.equal(newItem1[2])

            expect(item2.name).to.equal(newItem2[0])
            expect(item2.creator).to.equal(newItem2[1])
            expect(item2.checksum).to.equal(newItem2[2])

        })

        it("meta can be added and deleted", async function(){

            await catalogue.updateMeta(1, [['key1', 'value1']]);
            expect(await catalogue.getMeta(1, 'key1')).to.equal('value1');

            await catalogue.updateMeta(2, [['key2', 'value2']]);
            expect(await catalogue.getMeta(2, 'key2')).to.equal('value2');

            await catalogue.deleteMeta(1, ['key1']);
            expect(await catalogue.getMeta(1, 'key1')).to.equal('');
            
            await catalogue.deleteMeta(2, ['key2']);
            expect(await catalogue.getMeta(2, 'key2')).to.equal('');

        });

        it("sources can be added", async function(){

            await catalogue.addSources(1, ['https://ding.bat/file1'])
            await catalogue.addSources(1, ['https://ding.bat/file2', 'https://ding.bat/file3']);
            await catalogue.addSources(2, ['https://dang.bit/file1'])
            await catalogue.addSources(2, ['https://dang.bit/file2', 'https://dang.bit/file3']);

            const item1 = await catalogue.getItem(1);
            const item2 = await catalogue.getItem(2);

            expect(item1.sources.length).to.equal(4);
            expect(item2.sources.length).to.equal(4);

        });


    })


    describe("item access", async function(){

        it("only manager can administer item access", async function(){

            // Check positive
            await catalogue.grantItemAccess(user2.address, 1, 'add_sources');
            await catalogue.grantItemAccess(user2.address, 1, 'update_item');
            await catalogue.grantItemAccess(user2.address, 1, 'update_meta');
            await catalogue.grantItemAccess(user2.address, 2, 'add_sources');
            await catalogue.grantItemAccess(user2.address, 2, 'update_item');
            await catalogue.grantItemAccess(user2.address, 2, 'update_meta');
    
            expect(await catalogue.hasItemAccess(user2.address, 1, 'add_sources')).to.be.true;
            expect(await catalogue.hasItemAccess(user2.address, 1, 'update_item')).to.be.true;
            expect(await catalogue.hasItemAccess(user2.address, 1, 'update_meta')).to.be.true;
            expect(await catalogue.hasItemAccess(user2.address, 2, 'add_sources')).to.be.true;
            expect(await catalogue.hasItemAccess(user2.address, 2, 'update_item')).to.be.true;
            expect(await catalogue.hasItemAccess(user2.address, 2, 'update_meta')).to.be.true;
    
            // Check negative
            await expect(catalogue.connect(user2).grantItemAccess(user3.address, 1, 'add_sources')).to.be.revertedWith('AccessControl: ');
            await expect(catalogue.connect(user2).grantItemAccess(user3.address, 1, 'update_item')).to.be.revertedWith('AccessControl: ');
            await expect(catalogue.connect(user2).grantItemAccess(user3.address, 1, 'update_meta')).to.be.revertedWith('AccessControl: ');
            await expect(catalogue.connect(user3).grantItemAccess(user2.address, 1, 'add_sources')).to.be.revertedWith('AccessControl: ');
            await expect(catalogue.connect(user3).grantItemAccess(user2.address, 1, 'update_item')).to.be.revertedWith('AccessControl: ');
            await expect(catalogue.connect(user3).grantItemAccess(user2.address, 1, 'update_meta')).to.be.revertedWith('AccessControl: ');
    
        })
    
        it("only those with item access 'update_item' can update item", async function(){
    
            // Check positive
            await expect(catalogue.updateItemName(1, 'New name 1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.updateItemCreator(1, 'New creator 1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.updateItemChecksum(1, 'NewChecksumForItem1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.updateItem(2, 'New name 2', 'New creator 2', 'NewChecksumForItem2')).to.emit(catalogue, 'itemUpdated').withArgs(2)
    
            await expect(catalogue.connect(user2).updateItemName(1, 'New name 1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.connect(user2).updateItemCreator(1, 'New creator 1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.connect(user2).updateItemChecksum(1, 'NewChecksumForItem1')).to.emit(catalogue, 'itemUpdated').withArgs(1);
            await expect(catalogue.connect(user2).updateItem(2, 'New name 2', 'New creator 2', 'NewChecksumForItem2')).to.emit(catalogue, 'itemUpdated').withArgs(2)
    
    
            // Check negative
            await expect(catalogue.connect(user3).updateItemName(1, 'New name 1')).to.be.revertedWith('MISSING_ITEM_ACCESS')
            await expect(catalogue.connect(user3).updateItemCreator(1, 'New creator 1')).to.be.revertedWith('MISSING_ITEM_ACCESS')
            await expect(catalogue.connect(user3).updateItemChecksum(1, 'NewChecksumForItem1')).to.be.revertedWith('MISSING_ITEM_ACCESS')
            await expect(catalogue.connect(user3).updateItem(2, 'New name 2', 'New creator 2', 'NewChecksumForItem2')).to.be.revertedWith('MISSING_ITEM_ACCESS')
    
        });
    
    
        it("only those with item access 'update_meta' can add meta", async function(){
    
            // Check positive
            await expect(catalogue.updateMeta(1, [['key1', 'value1']])).to.emit(catalogue, 'metaUpdated').withArgs(1, 'key1', 'value1');
            await expect(catalogue.updateMeta(2, [['key2', 'value2']])).to.emit(catalogue, 'metaUpdated').withArgs(2, 'key2', 'value2');
    
            // Check negative
            await expect(catalogue.connect(user3).updateMeta(1, [['key1', 'value1']])).to.be.revertedWith('MISSING_ITEM_ACCESS');
            await expect(catalogue.connect(user3).updateMeta(2, [['key2', 'value2']])).to.be.revertedWith('MISSING_ITEM_ACCESS');
    
        });
    
    
    
        it("only those with item access 'add_sources' can add item sources", async function(){
    
            // Check positive
            await expect(catalogue.addSources(1, ['https://new.source/1.file'])).to.emit(catalogue, 'sourceAdded').withArgs(1, 'https://new.source/1.file');
            await expect(catalogue.addSources(2, ['https://new.source/2.file'])).to.emit(catalogue, 'sourceAdded').withArgs(2, 'https://new.source/2.file');
    
            // Check negative
            await expect(catalogue.connect(user3).addSources(1, ['https://new.source/1.file'])).to.be.revertedWith('MISSING_ITEM_ACCESS');
            await expect(catalogue.connect(user3).addSources(2, ['https://new.source/2.file'])).to.be.revertedWith('MISSING_ITEM_ACCESS');
            
        });
    
    })    

    

});