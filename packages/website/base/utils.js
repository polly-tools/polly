import { ethers } from "ethers";

export const chains = {
    1: "mainnet",
    5: "goerli",
    31337: "localhost"
}

export function truncate(input, length, append = '...') {
    if(input.length > length)
       return input.substring(0, length)+append;
    return input;
};

export function chainToName(id){
    return chains[id];
}


export function parseReturnParam(param){
  return {
      _uint: param[0],
      _int: param[1],
      _bool: param[2],
      _string: param[3],
      _address: param[4]
  };

}


export function parseConfig(config){
  return {
      name: config[0] ? config[0] : config[1],
      module: config[1],
      version: config[2],
      params: config[3].map(parseReturnParam)
  }

}
