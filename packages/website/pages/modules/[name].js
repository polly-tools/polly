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
import ModuleInterface, { ModuleInterfaceProvider, useModuleInterface } from "components/ModuleInterface";
import Address from "components/Address";

const nullAddress = '0x0000000000000000000000000000000000000000';

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

export async function handleConfigure(account, polly, name, version, params, store, configName){


    const conf_fee = await polly.read('getConfiguratorFee', {
      for_: account,
      name_: name,
      version_: version,
      params_: params
    }).then(fee => fee.result)

    const fee = await polly.read('fee', {
      for_: account,
      value_: conf_fee
    }).then(fee => fee.result)

    await polly.write('configureModule', {
        name_: name,
        version_: version,
        params_: params,
        store_: store,
        configName_: configName
    }, {
      value: fee+conf_fee
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

                <h1>Configure</h1>
                <p>
                    You are about to create a configuration of the module <em>{module.name}</em> and any dependencies it might have.
                </p>

                <div style={{marginBottom: '1em'}}>

                <label>Start by giving your new configuration a name for future reference</label>
                <input placeholder={module.name} type="text" onKeyUp={e => setConfigName(e.target.value)}/>

                </div>

                <ModuleInterface create/>

                <ModalActions actions={[
                    {label: 'Cancel', callback: () => p.onCancel()},
                    {label: account ? 'Deploy' : 'Connect to deploy', cta: true, callback: () => {
                        if(account)
                            handleConfigure(account, p.polly, module.name, module.version, userInputs, true, configName)
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

    const polly = usePolly();
    const [showCloneScreen, setShowCloneScreen] = useState(false);

    const MDX = moduleMDX[p.name] ? moduleMDX[p.name] : false;

    return <Page header>
        <Grid>
            <Grid.Unit size={1/1}>

            <h1 className="compact">{p.name}</h1>
            <small>v{p.version} | <Address address={p.implementation}/> | {p.configurator && <><a href="#" onClick={() => setShowCloneScreen(true)}>CONFIGURE</a> | </>} <a href={etherscanLink(p.implementation)} target="_blank">CODE</a></small>
            <br/>
            <br/>
            <p>{p.info}</p>

            </Grid.Unit>
            <Grid.Unit size={1/1}>
            {p.configurator &&
            <ModuleInterfaceProvider name={p.name}>
                <DeployModuleScreen polly={polly} onCancel={() => setShowCloneScreen(false)} show={showCloneScreen}/>
            </ModuleInterfaceProvider>
            }
            </Grid.Unit>
            <Grid.Unit>
                {MDX && <MDX {...p}/>}
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
    const configurator = await moduleContract.configurator()
    let inputs = [];
    let outputs = [];
    if(configurator != nullAddress){
      const configContract = new ethers.Contract(configurator, configABI, provider);
      inputs = await configContract.inputs();
      outputs = await configContract.outputs();
    }

    return {
        props: {
            name: module.name,
            version: module.version.toNumber(),
            clone: module.clone,
            implementation: module.implementation,
            configurator: configurator != nullAddress ? configurator : false,
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
