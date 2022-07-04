const PollyConfigurator = require('@polly-os/core/utils/PollyConfigurator');

class CollectionAuxHandler extends PollyConfigurator {

    
    static requiredOptions = {
        collection: true,
        catalogue: true
    }
    
    async configure(){
        
        const {catalogue, aux_handler, collection} = this.options;
        
        await catalogue.grantRole(this.roles.MANAGER, this.module.address);
        await collection.grantRole(this.roles.MANAGER, this.module.address);

        // await this.module.setAddress('collection', collection.address);

        if(await collection.getAddress('aux_handler') != aux_handler.address){
            await collection.setAddress('aux_handler', aux_handler.address);
            await this.module.grantRole(this.roles.MANAGER, collection.address);
        }

    }

}

module.exports = CollectionAuxHandler;