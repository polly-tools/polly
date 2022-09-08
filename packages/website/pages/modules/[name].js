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
import { ConnectIntent, useConnectIntent } from "components/ConnectButton";
import { getProvider } from "base/provider";
import pollyABI from '@polly-os/core/abi/Polly.json';
import moduleABI from '@polly-os/core/abi/PollyModule.json';
import configABI from '@polly-os/core/abi/PollyConfigurator.json';
import { paramCase } from "param-case";
import { ethers } from "ethers";
import moduleMDX from "mdx/modules"
import useModule from "base/hooks/useModule";
import ModuleInterface, { ModuleInterfaceProvider, useModuleInterface } from "components/ModuleInterface/ModuleInterface";


function etherscanLink(append_){
    if(process.env.NEXT_PUBLIC_NETWORK_ID == 5)
        return `https://goerli.etherscan.io/address/${append_}`;

    return `https://etherscan.io/address/${append_}`;
}

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hyphenToCC(string){
    return capitalizeFirstLetter(string.replace(/-([a-z])/g, (m, s) => {
        return s.toUpperCase();
    }));
}

export async function handleClone(polly, name, version, params, store, configName){
    // console.log('handleClone', name, version, params, store, polly);
    await polly.write('configureModule', {
        name_: name,
        version_: version,
        params_: params,
        store_: store,
        configName_: configName
    });
}

export function DeployModuleScreen(p){


    const {account} = useWeb3React();
    const [configName, setConfigName] = useState('');
    const {module, inputs, outputs, userInputs} = useModuleInterface();
    const {setConnectIntent} = useConnectIntent();

    return <Modal show={p.show}>

        <ModalInner>
            {(module) ? <>

                <h1>Clone module</h1>
                <p>
                    You are about to create a configuration of the module <em>{module.name}</em> and any dependencies it might have.
                </p>

                <div style={{marginBottom: '1em'}}>

                <label>Start by giving your new configuration a name</label>
                <input placeholder={module.name} type="text" onKeyUp={e => setConfigName(e.target.value)}/>

                </div>

                <ModuleInterface create/>

                <ModalActions actions={[
                    {label: 'Cancel', callback: () => p.onCancel()},
                    {label: account ? 'Deploy' : 'Connect to deploy', cta: true, callback: () => {
                        if(account)
                            handleClone(p.polly, module.name, module.version, userInputs, true, configName)
                        else
                            setConnectIntent(true);
                    }
                }]}/>

            </>
            :
            <>Loading...</>}



        </ModalInner>
    </Modal>

}

export default function Module(p){

    const [inputs, setInputs] = useState([]);
    const {query} = useRouter();
    const polly = usePolly();
    const {account} = useWeb3React();
    const [showCloneScreen, setShowCloneScreen] = useState(false);
    const {setConnectIntent} = useConnectIntent();

    const MDX = moduleMDX[p.name];

    return <Page header>
        <Grid>
            <Grid.Unit size={1/1}>

            <h1 className="compact">{p.name}</h1>
            <small>v{p.version} | {p.clone ? <a href="#" onClick={() => setShowCloneScreen(true)}>CLONE</a> : 'READ-ONLY'} | <a href={etherscanLink(p.implementation)} target="_blank">CODE</a></small>
            <br/>
            <br/>
            <p>{p.info}</p>

            </Grid.Unit>
            <Grid.Unit size={1/1}>
            {p.clone &&
            <ModuleInterfaceProvider name={p.name}>
                <DeployModuleScreen polly={polly} onCancel={() => setShowCloneScreen(false)} show={showCloneScreen}/>
            </ModuleInterfaceProvider>
            }
            </Grid.Unit>
            <Grid.Unit>
                {module && <MDX module={module}/>}
            </Grid.Unit>

        </Grid>
    </Page>

}


export async function getStaticProps({params}){

    const provider = getProvider();
    const contract = new ethers.Contract(process.env.POLLY_ADDRESS, pollyABI, provider);

    const module = await contract.getModule(
        hyphenToCC(params.name),
        0
    );

    const moduleContract = new ethers.Contract(module.implementation, moduleABI, provider);
    const configContract = new ethers.Contract(await moduleContract.configurator(), configABI, provider);
    const inputs = await configContract.inputs();
    const outputs = await configContract.outputs();

    return {
        props: {
            name: module.name,
            info: module.info,
            version: module.version.toNumber(),
            clone: module.clone,
            implementation: module.implementation,
            inputs: inputs,
            outputs: outputs,
        }
    }
}


export async function getStaticPaths(){

    const provider = getProvider();
    const contract = new ethers.Contract(process.env.POLLY_ADDRESS, pollyABI, provider);
    const modules = await contract.getModules(0, 0, false);

    return {
        paths: modules.map(module => ({
            params: {
                name: paramCase(module[0])
            }
        })),
        fallback: false
    }
}
