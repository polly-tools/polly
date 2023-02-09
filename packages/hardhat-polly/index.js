require('./tasks.js')

extendEnvironment(async (hre) => {

  let polly;

  const verbose = hre.config?.polly?.verbose;
  const fork = hre.config?.polly?.fork[hre.network.name];

  function log(msg){
    if(verbose)
      console.log(msg);
  }

  hre.polly = {
    forked: false,
    contract: null
  };




  hre.polly.forked = (fork);

  if(hre.polly.forked)
    log('Forking Polly at -> '+fork.green);

  hre.polly.deploy = async function(force_deploy = false){

    if(hre.polly.forked && !force_deploy){

      polly = await hre.ethers.getContractAt('Polly', fork);
      log('Using forked Polly at -> '+polly.address.green);
      return polly;

    }
    else {

      const Polly = await ethers.getContractFactory("Polly");
      polly = await Polly.deploy();
      log('Deployed Polly at -> '+polly.address.green);
      return polly;

    }

  }

  hre.polly.use = async function(address){
    polly = await hre.ethers.getContractAt('Polly', address);
    log('Using Polly at -> '+polly.address.green);
    return polly;
  }


  hre.polly.contract = polly;


  hre.polly.addModule = async (name, ...args) => {

    // Module
    const Module = await hre.ethers.getContractFactory(name);
    const module = await Module.deploy(...args);
    await module.deployed();

    // Add module handler to Polly
    const tx = await polly.updateModule(module.address);
    log('Adding module -> '+name.green+' at -> '+module.address.green);
    const receipt = await tx.wait();

    const events = receipt.events.filter(e => e.event === 'moduleUpdated');
    const [indexedname, _name, _version, address] = events[events.length-1].args;
    const polly_module = await polly.getModule(_name, _version);

    return polly_module;

  }


  hre.polly.configureModule = async (name, options = {}, msg = {}) => {

    const [owner] = await hre.ethers.getSigners();

    const {
      signer,
      ...o
    } = Object.assign({
      version: 0, // Latest version
      params: [], // No params
      store: true, // Store config in Polly
      configName: '', // No config name
      signer: owner // Default signer
    }, options);


    // Configure MetaForIds
    const tx = await polly.connect(signer).configureModule(
      name, // Name
      o.version, // Latest version
      o.params, // No params
      o.store, // Store config in Polly
      o.configName, // No config name
      msg
    );

    const receipt = await tx.wait();
    const args = receipt.events.filter(x => x.event === "moduleConfigured").map(event => event.args[2]);
    const index = args[args.length-1];
    const config = await polly.getConfigForAddress(signer.address, index);
    module = await ethers.getContractAt(`${name}`, config.params[0]._address);
    return [module, config];

  }



});
