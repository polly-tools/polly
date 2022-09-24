import { ethers } from "ethers";
import { useEffect, useState } from "react";
import fetch from 'node-fetch';
import { useWeb3React } from "@web3-react/core";
import { isObject, values } from "lodash";

function objectToArray(input){

    const arr = [];

    for (const key in input) {

        if (Object.hasOwnProperty.call(input, key)) {
            if(isObject(input[key]))
                arr.push(objectToArray(input[key]));
            else
                arr.push(input[key]);
        }
    }

    return arr;

}


export default function useContract(options){

    const [contract, setContract] = useState();
    const {library, account} = useWeb3React();
    const [address, setAddress] = useState(options.address);

    useEffect(() => {

        if(account && library && address){
            const {abi} = options;
            const _contract = new ethers.Contract(address, abi, library.getSigner());
            setContract(_contract);
        }

    }, [address, account, library])


    async function read(method, args = false, controller = false){

        const {endpoint} = options;
        const req = `${endpoint}/${method}`;

        return _readGET(req, args, controller).then(res => res.json());

    }

    function _readPOST(req, args = false, controller = false){

      return fetch(req, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(args),
        signal: controller ? controller.signal : null,
      })

    }

    function _readGET(req, args = false, controller = false){

      if(args)
        req = req+'?data='+encodeURIComponent(JSON.stringify(args));

      return fetch(req, {
        method: 'GET',
        signal: controller ? controller.signal : null,
      })

    }



    async function write(method, args, extra = null){
        if(contract){
            const _args = objectToArray(args);
            return contract[method](..._args, extra)
        }
    }


    return {read, write, setAddress, contract};

}
