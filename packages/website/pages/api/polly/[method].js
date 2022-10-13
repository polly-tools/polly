import pollyABI from '@polly-tools/core/abi/Polly.json';
import { ethers } from "ethers";
import ABIAPI from 'abiapi';
import { getProvider } from "base/provider";
import { isArray, isObject } from 'lodash';
import { parseConfig } from "base/utils";
import getQuery from 'base/api/getQuery';

const abi = new ABIAPI(pollyABI);
abi.supportedMethods = abi.getReadMethods();
abi.cacheTTL = 60*60;

// NUMBER PARSER
function bigNumbersToNumber(value){

    if(value._isBigNumber){
        return value.toNumber();
    }
    else if(isArray(value)){
        return value.map(bigNumbersToNumber);
    }
    else if(isObject(value)){

        for(const key in value) {
            if (Object.hasOwnProperty.call(value, key)) {
                value[key] = bigNumbersToNumber(value[key])
            }
        }
        return value;
    }

    return value;

}
abi.addGlobalParser(bigNumbersToNumber)

function moduleParser(module){

    return {
      name: module[0],
      version: module[1],
      implementation: module[2],
      clonable: module[3]
  }

}
abi.addParser('getModule', moduleParser)
abi.addParser('getModules', (modules) => modules.filter(mod => mod[0] !== '').map(moduleParser))
abi.addParser('getConfigsForAddress', (configs) => configs.map(parseConfig));

export default async (req, res) => {

    const data = {};
    const {method, ...query} = getQuery(req);
    if(abi.supportsMethod(method)){

        const provider = getProvider();
        const contract = new ethers.Contract(process.env.POLLY_ADDRESS, pollyABI, provider);

        try {
            data.result = await contract[method](...abi.methodParamsFromQuery(method, query));
            data.result = abi.parse(method, data.result);
        }
        catch(e){
            data.error = e.toString();
        }

    }
    else{
        data.error = 'Unsupported method';
    }

    const status = data.error ? 400 : 200;

    if(status == 200)
        res.setHeader(`Cache-Control`, `s-maxage=${abi.getMethodCacheTTL(method)}, stale-while-revalidate`)

    res.status(status).json(data);


}
