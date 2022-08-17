import Page from 'templates/Page.js';
import Grid from 'styled-components-grid';
import useContract from 'base/hooks/useContract';
import pollyABI from '@polly-os/core/abi/Polly.json';
import { useEffect, useState } from 'react';
import { useWeb3React } from '@web3-react/core';
import { isArray } from 'lodash';

export default function Configs(p){

    const [configs, setConfigs] = useState(-1);
    const {account} = useWeb3React();

    const polly = useContract({
        address: process.env.NEXT_PUBLIC_POLLY_ADDRESS,
        abi: pollyABI,
        endpoint: '/api/polly'
    });


    useEffect(() => {
        
        if(polly && account){
            setConfigs(-1);
            polly.read('getConfigsForAddress', {address_: account, limit_: 1, page_: 1}).then(response => {
                setConfigs(response.result);
            }).catch(err => {
                console.log(err);
            });
        }

    }, [account])

    return <Page header>
        <Grid.Unit size={{sm: 1/1}} style={{marginBottom: '7em'}}>
            <h2>Configurations</h2>
            {account && <>

                {configs === -1 && <div>Loading...</div>}
                {(isArray(configs) && configs.length > 0) && configs.map((config, index) => {
                    return <div key={index}>
                       ________________________________
                        <br/><br/>
                        <div>
                            {config.name}
                        </div>
                        <div>
                            {config.params.length} parameter{config.params.length > 1 ? 's' : ''}
                        </div>
                    </div>
                })}
            
            </>}

            {!account && <span>Connect to view your configs</span>}

        </Grid.Unit>
    </Page>

}