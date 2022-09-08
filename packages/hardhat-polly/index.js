extendEnvironment(async (hre) => {

  let polly;

  const {verbose} = hre.config.polly;
  const fork = hre.config.polly.fork[hre.network.name];

  function log(msg){
    if(verbose)
      console.log(msg);
  }

  hre.polly = {
    forked: false,
    contract: null
  };


  if(fork){
    hre.polly.forked = true;
    hre.polly.deploy = async function(){
      polly = await hre.ethers.getContractAt('Polly', fork);
      log('Using forked Polly at -> '+polly.address.green);
      return polly;
    }
  }
  else {
    hre.polly.deploy = async function(){
      const Polly = await ethers.getContractFactory("Polly");
      polly = await Polly.deploy();
      log('Deployed Polly at -> '+polly.address.green);
      return polly;
    }
  }


  hre.polly.contract = polly;


  hre.polly.addModule = async (name) => {

    // Module
    const Module = await hre.ethers.getContractFactory(name);
    const module = await Module.deploy();
    await module.deployed();

    // Add module handler to Polly
    await polly.updateModule(module.address);
    const polly_module = await polly.getModule(name, 0);

    return polly_module;

  }



});
