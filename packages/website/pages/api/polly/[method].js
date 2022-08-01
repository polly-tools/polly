import pollyABI from '@polly-os/core/abi/Polly.json';
import { ethers } from "ethers";
import ABIAPI from 'abiapi';
import { getProvider } from "../../../base/provider";
import { isArray, isArrayLikeObject, isObject, isObjectLike } from 'lodash';

const abi = new ABIAPI(pollyABI);
abi.supportedMethods = abi.getReadMethods();
abi.cacheTTL = 60*60;

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
        location: module[2]
    }
}
abi.addParser('getModule', moduleParser)
abi.addParser('getConfig', function(config){
    return {
        name: config[0],
        owner: config[1],
        modules: config[2].map(moduleParser)
    }
});

export default async (req, res) => {

    const data = {};
    const {method, ...query} = req.query;

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