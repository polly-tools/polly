import useContract from "./useContract";
import { useState, useEffect} from "react";
import { usePolly } from "./usePolly";


export default function useModule(options = {}){
    
    const [name, setName] = useState(options.name);
    const [version, setVersion] = useState(options.version);
    const [module, setModule] = useState(false);
    const [info, setInfo] = useState(false);
    const [fetching, setFetching] = useState(false);
    const polly = usePolly();

    async function fetchModule(name, version){
        setFetching(true);
        const _module = await polly.read('getModule', {name_: name, version_: version}).then(res => res.result);
        const info = await fetch(`/api/module/${name}/configurator/info?version=${version}`).then(res => res.json()).then(res => res.result);
        setModule(_module)
        setInfo(info)
        setFetching(false);
    }

    useEffect(() => {
        if(name)
            fetchModule(name, version > 0 ? parseInt(version) : 0);
    }, [name, version])

    return {
        setName,
        setVersion,
        fetching,
        module,
        info
    };

}