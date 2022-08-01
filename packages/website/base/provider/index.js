import {ethers} from 'ethers';

export function getProvider(){
    return new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
}