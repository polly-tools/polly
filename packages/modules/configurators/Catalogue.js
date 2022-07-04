const PollyConfigurator = require('@polly-os/core/utils/PollyConfigurator');

class Catalogue extends PollyConfigurator {

    static requiredOptions = {
        collection: true
    }

    async configure(){
        // const {collection} = this.options;
        // await this.module.grantRole(this.roles.MANAGER, collection.address);
    }

}

module.exports = Catalogue;