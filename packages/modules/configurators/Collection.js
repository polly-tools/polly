const PollyConfigurator = require('@polly-os/core/utils/PollyConfigurator');

class Collection extends PollyConfigurator {

    static name = 'polly.Collection';
    static requiredOptions = {
        catalogue: true
    }

    async configure(){
        const {catalogue} = this.options;
        await this.module.setAddress('catalogue', catalogue.address);
        await catalogue.grantRole(this.roles.MANAGER, this.module.address);
        await this.module.setAddress('catalogue', catalogue.address);
    }

}

module.exports = Collection;