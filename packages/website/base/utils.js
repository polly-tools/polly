import { ethers } from "ethers";

export const chains = {
    1: "mainnet",
    4: "rinkeby",
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