import { useState, useEffect} from "react";
import { usePolly } from "./usePolly";

const nullAddress = '0x0000000000000000000000000000000000000000';

export default function useModule(options = {}){

    const [address, setAddress] = useState(options.address);
    const [name, setName] = useState(options.name);
    const [version, setVersion] = useState(options.version);
    const [module, setModule] = useState(false);
    const [inputs, setInputs] = useState(false);
    const [outputs, setOutputs] = useState(false);
    const [fetching, setFetching] = useState(true);
    const polly = usePolly();

    async function fetchModuleFromAddress(address){

      let pmname, pmversion;

      await Promise.all([
        fetch(`/api/module/at/${address}/PMNAME`).then(res => res.json()).then(res => pmname = res.result),
        fetch(`/api/module/at/${address}/PMVERSION`).then(res => res.json()).then(res => pmversion = res.result)
      ]);


      if(pmname){
        setName(pmname);
        setVersion(pmversion);
      }

    }

    async function fetchModule(name, version){

      setFetching(true);

      const _module = await polly.read('getModule', {name_: name, version_: version}).then(res => res.result);
      const hasConfigurator = await fetch(`/api/module/${name}/configurator`).then(res => res.json()).then(res => res.result != nullAddress ? true : false);
      setModule(_module)

      if(hasConfigurator){
        const inputs = await fetch(`/api/module/${name}/configurator/inputs?version=${version}`).then(res => res.json()).then(res => res.result);
        const outputs = await fetch(`/api/module/${name}/configurator/outputs?version=${version}`).then(res => res.json()).then(res => res.result);
        setInputs(inputs)
        setOutputs(outputs)
      }

      setFetching(false);

    }

    // useEffect(() => {
    //   if(options.address)
    //     fetchModuleFromAddress(options.address);
    //   else
    //   if(options.name)
    //     fetchModule(options.name, options.version > 0 ? parseInt(options.version) : 0);
    // }, [])

    useEffect(() => {
      if(name)
        fetchModule(name, version > 0 ? parseInt(version) : 0);
    }, [name, version])

    useEffect(() => {
      if(address)
        fetchModuleFromAddress(address);
    }, [address])

    return {
        setName,
        setVersion,
        setAddress,
        fetching,
        name,
        version,
        address,
        module,
        inputs,
        outputs
    };

}
