import configABI from '@polly-os/core/abi/PollyConfigurator.json';
import { ethers } from "ethers";
import ABIAPI from 'abiapi';
import { getProvider } from "base/provider";
import { isArray, isObject } from 'lodash';
import getBaseUrl from 'base/url';

const abi = new ABIAPI(configABI);
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

function parseInputsOutputs(param){

    const parts = param.split('|').map(part => part.trim());

    if(parts.length < 2){
        return false;
    }

    return {
        type: parts[0],
        name: parts[1],
        description: parts[2]
    }
}

abi.addParser('inputs', (inputs) => {
  return inputs.map(parseInputsOutputs).filter(res => res);
})
abi.addParser('outputs', (outputs) => {
  return outputs.map(parseInputsOutputs).filter(res => res);
})


function parseReturnParam(param){

    return {
        _string: param[0],
        _uint: param[1],
        _int: param[2],
        _bool: param[3],
        _address: param[4]
    };

}

function parseConfig(config){
    return {
        name: config[0],
        params: config[1].map(parseReturnParam)
    }

}

abi.addParser('getConfigsForAddress', (configs) => configs.filter(config => config[0] !== '').map(parseConfig));

export default async (req, res) => {

    const data = {};
    const {name, method, version, ...query} = req.query;

    const configurator = await fetch(`${getBaseUrl()}/api/module/${name}/configurator?version_=${version ? version : 0}`).then(res => res.json()).then(res => res.result);

    if(abi.supportsMethod(method)){

        const provider = getProvider();
        const contract = new ethers.Contract(configurator, configABI, provider);

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
