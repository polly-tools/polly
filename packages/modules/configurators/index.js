const configs = [];
configs.collection = require('../polly_configurators/Collection.js');
configs.catalogue = require('../polly_configurators/Catalogue.js');
configs.aux_handler = require('./CollectionAux.js');
configs.chains = require('../polly_configurators/Chains.js');

module.exports = async function(options){

    for (const key in configs) {
        if (Object.hasOwnProperty.call(configs, key)) {
            configs[key] = new configs[key](options[key], options);
            await configs[key].configure();              
        }
    }

}