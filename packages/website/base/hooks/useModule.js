import useContract from "./useContract";
import { useState, useEffect} from "react";
import { usePolly } from "./usePolly";


export default function useModule(options = {}){

    const [name, setName] = useState(options.name);
    const [version, setVersion] = useState(options.version);
    const [module, setModule] = useState(false);
    const [inputs, setInputs] = useState(false);
    const [outputs, setOutputs] = useState(false);
    const [fetching, setFetching] = useState(false);
    const polly = usePolly();

    async function fetchModule(name, version){
        setFetching(true);
        const _module = await polly.read('getModule', {name_: name, version_: version}).then(res => res.result);
        setModule(_module)

        if(_module.clonable){
          const inputs = await fetch(`/api/module/${name}/configurator/inputs?version=${version}`).then(res => res.json()).then(res => res.result);
          const outputs = await fetch(`/api/module/${name}/configurator/outputs?version=${version}`).then(res => res.json()).then(res => res.result);
          setInputs(inputs)
          setOutputs(outputs)
        }

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
        inputs,
        outputs
    };

}
