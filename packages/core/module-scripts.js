const MusicToken = {
  deploy: async (Module) => {
    const module = await Module.deploy(process.env.POLLY_ADDRESS);
    await module.deployed();
    return module.address;
  }
}


module.exports = {
  MusicToken
}
