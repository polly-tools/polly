require('./tasks.js')

extendEnvironment(async (hre) => {

  let polly;

  const verbose = hre.config?.polly?.verbose;
  const fork = hre.config?.polly?.networks[hre.network.name];

  function log(msg){
    if(verbose)
      console.log(msg);
  }

  if(typeof fork == 'string'){
    try {
      polly = await hre.ethers.getContractAt('Polly', fork);
      log(`Using Polly installation at address ${polly.address.green} on network ${hre.network.name}`);
    }
    catch(e){
      console.log(`Error: ${e.message}`);
    }
  }

  hre.polly = polly;

});
