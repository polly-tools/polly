import Page from 'templates/Page.js';
import Grid from 'styled-components-grid';
import useContract from 'base/hooks/useContract';
import pollyABI from '@polly-os/core/abi/Polly.json';
import { useEffect, useState } from 'react';
import { useWeb3React } from '@web3-react/core';
import {paramCase} from 'param-case'
import Link from 'next/link'


export default function Modules(p){

    const [modules, setModules] = useState(-1);
    const {account} = useWeb3React();

    const polly = useContract({
        address: process.env.NEXT_PUBLIC_POLLY_ADDRESS,
        abi: pollyABI,
        endpoint: '/api/polly'
    });


    useEffect(() => {
        
        if(polly){
            setModules(-1);
            polly.read('getModules', {page_: 1, limit_: 50, ascending_: false}).then(response => {
                const mods = response.result;
                setModules(mods);
            }).catch(err => {
                console.log(err);
            });
        }

    }, [])

    return <Page header>
        <Grid.Unit size={{sm: 1/1}} style={{marginBottom: '7em'}}>
            <h2>Modules</h2>
            {modules === -1 && <div>Loading...</div>}
            {modules.length > 0 && modules.map((module, index) => {
                return <div key={index}>
                    ________________________________
                    <br/><br/>
                    <div>
                        <Link href={`/modules/${paramCase(module.name)}`}>
                            <a>
                                {module.name}
                            </a>                        
                        </Link>
                        <br/>
                        <small>v{module.version} | {module.clonable ? 'CLONABLE' : 'READ-ONLY'}</small>
                        
                    </div>
                </div>
            })}
        </Grid.Unit>
    </Page>

}