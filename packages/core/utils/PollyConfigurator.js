const keccak256 = require('keccak256')

class PollyConfigurator {

  constructor(module, options){
    this.module = module;
    this._parseOptions(options);
    this.options = options;
    this.roles = {
      MANAGER: '0x'+keccak256('MANAGER').toString('hex')
    };
  }


  _parseOptions(options){
    for(const key in this.requiredOptions){
      if(Object.hasOwnProperty.call(this.requiredOptions, key)) {
        if(typeof this.options[key] === 'undefined')
          throw `"${key}" is a required option for module ${this.name}`;
      }
    }
  }


}


module.exports = PollyConfigurator;
