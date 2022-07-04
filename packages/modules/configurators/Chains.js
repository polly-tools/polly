const PollyConfigurator = require('@polly-os/core/utils/PollyConfigurator');
const { expect } = require('chai');

class Chains extends PollyConfigurator {
    
    static requiredOptions = {
        collection: true,
        catalogue: true
    }

    async configure(){
        
        const {collection, aux_handler, catalogue} = this.options;
        await this.module.setAddress('collection', collection.address);
        await collection.grantRole(this.roles.MANAGER, this.module.address);
        await catalogue.grantRole(this.roles.MANAGER, this.module.address);
        await aux_handler.addAux(this.module.address);
    }


}

module.exports = Chains;