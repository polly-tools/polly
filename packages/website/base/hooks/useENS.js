import { ethers } from "ethers";
import { useEffect, useState } from "react";

export default function useENS(init = false){

    const [resolving, setResolving] = useState(false);
    const [ENS, setENS] = useState(false);
    const [address, setAddress] = useState(false)

    async function resolve(input, provider = false){

        const reverse = !input.match(/\.eth$/i);

        setResolving(true);
    
        try {
            if(reverse){
                setAddress(input)
                const name = provider ? await provider.lookupAddress(input) : await ethers.getDefaultProvider().lookupAddress(input)
                setResolving(false);
                setENS(name)
            }
            else {
                setENS(input)
                const address = provider ? await provider.resolveName(input) : await ethers.getDefaultProvider().resolveName(input)
                setResolving(false);
                setAddress(address);
            }
        } catch(e) {
          console.log(e)
        }

    };

    useEffect(() => {
        if(init)
            resolve(init)
        return () => {
            setENS(false);
            setAddress(false);
            setResolving(false);
        }
    }, []);

    return {resolve, resolving, ENS, address};

}