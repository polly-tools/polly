import { useWeb3React } from "@web3-react/core";
import useContract from "base/hooks/useContract"
import { usePolly } from "base/hooks/usePolly"
import { useRouter } from "next/dist/client/router";
import { useEffect, useState } from "react";
import Grid from "styled-components-grid";
import Page from "templates/Page";
import ModuleOutput from "components/ModuleOutputs/ModuleOutput";

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hyphenToCC(string){
    return capitalizeFirstLetter(string.replace(/-([a-z])/g, (m, s) => {
        return s.toUpperCase();
    }));
}

export default function Config({p}){

    const [config, setConfig] = useState(-1);
    const {query} = useRouter();
    const polly = usePolly();
    const {account} = useWeb3React();
    const [outputs, setOutputs] = useState(false);

    async function fetchConfig(address, index){
        const _config = await polly.read('getConfigsForAddress', {address_: address, limit_: 1, page_: index, ascending_: false}).then(res => res.result[0]);
        const _outputs = await fetch(`/api/module/${_config.module}/configurator/outputs?version=${_config.version}`).then(res => res.json()).then(res => res.result);
        setConfig(_config)
        setOutputs(_outputs)
    }

    useEffect(() => {
        if(account && query.index)
            fetchConfig(account, query.index);

    }, [account, query.index])

    return <Page header>
        {!account && <>Connect to view your configuration</>}
        {(account && !config && !outputs) && <>Loading...</>}
        {(account && config && outputs) && <Grid.Unit>
            <h1>{config.name}</h1>

            {outputs && outputs.map((output, index) => {
                return <ModuleOutput param={config.params[index]} output={output}/>
            })}
        </Grid.Unit>}
    </Page>

}
