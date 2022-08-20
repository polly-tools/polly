import useContract from "base/hooks/useContract"
import { usePolly } from "base/hooks/usePolly"
import Modal, { ModalActions, ModalInner } from "components/Modal";
import { useRouter } from "next/dist/client/router";
import { useEffect, useState } from "react";
import Grid from "styled-components-grid";
import Page from "templates/Page";
import { useWeb3React } from "@web3-react/core";
import Link from "next/link";
import Button from "components/Button";
import ModuleInput from "components/ModuleInputs/ModuleInput";

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hyphenToCC(string){
    return capitalizeFirstLetter(string.replace(/-([a-z])/g, (m, s) => {
        return s.toUpperCase();
    }));
}

export async function handleClone(polly, name, version, params, store){
    console.log('handleClone', name, version, params, store, polly);
    await polly.write('configureModule', {
        name_: name,
        version_: version,
        params_: params,
        store_: store
    });
}

export function DeployModuleScreen({module, actions, ...p}){

    return <Modal show={p.show}>
        <ModalInner>

            <h1>{module.name}</h1>
            <p>
                This will deploy a new version of the {module.name} module.
            </p>
            <ModalActions actions={actions}/>

        </ModalInner>
    </Modal>

}

export default function Module({p}){

    const [module, setModule] = useState(false);
    const [info, setInfo] = useState(false);
    const [inputs, setInputs] = useState([]);
    const {query} = useRouter();
    const polly = usePolly();
    const {account} = useWeb3React();

    const [showDeployScreen, setShowDeployScreen] = useState(false);

    async function fetchModule(){
        const name = hyphenToCC(query.name);
        const _module = await polly.read('getModule', {name_: name, version_: 0}).then(res => res.result);
        const _info = await fetch(`/api/module/${name}/configurator/info`).then(res => res.json()).then(res => res.result);
        setModule(_module)
        setInfo(_info)
    }

    useEffect(() => {
        if(query.name)
            fetchModule();
    }, [query.name])


    return <Page header>
        {module && <Grid.Unit>
            <h1>{module.name}</h1>
            <Grid.Unit size={1/2}>
            {info && <p>{info.description}</p>}
            {info && info.inputs.map((input, index) => <ModuleInput onChange={value => setInputs(prev => {prev[index] = value; return prev;})} key={index} input={input} module={module}/>)}
            </Grid.Unit>
            {account && <div>
                <Button onClick={() => setShowDeployScreen(true)}>
                    Deploy
                </Button>
                <DeployModuleScreen actions={[
                    {label: 'Cancel', callback: () => setShowDeployScreen(false)},
                    {label: 'Deploy', cta: true, callback: () => handleClone(polly, module.name, module.version, inputs, true)}
                ]} module={module} show={showDeployScreen}/>
            </div>}

        </Grid.Unit>}
    </Page>

}