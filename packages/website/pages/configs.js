import Page from 'templates/Page.js';
import Grid from 'styled-components-grid';
import useContract from 'base/hooks/useContract';
import pollyABI from '@polly-tools/core/abi/Polly.json';
import { useEffect, useState } from 'react';
import { useWeb3React } from '@web3-react/core';
import { isArray } from 'lodash';
import Link from 'next/link';
import { useConnectIntent } from 'components/ConnectButton';

export default function Configs(p){

    const [configs, setConfigs] = useState(-1);
    const {account} = useWeb3React();
    const [page, setPage] = useState(1);
    const {setConnectIntent} = useConnectIntent();

    const polly = useContract({
        address: process.env.NEXT_PUBLIC_POLLY_ADDRESS,
        abi: pollyABI,
        endpoint: '/api/polly'
    });


    useEffect(() => {

        if(polly && account){
            setConfigs(-1);
            polly.read('getConfigsForAddress', {address_: account, limit_: 50, page_: page, ascending_: false}).then(response => {
                const confs = response.result;
                setConfigs(confs);
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
                    const realIndex = (index+1)*page;
                    return <div key={realIndex}>
                       ________________________________
                        <br/><br/>
                        <div>
                            <Link href={`/configs/${realIndex}`}>
                                <a>
                                {config.name}
                                </a>
                            </Link>
                        </div>
                    </div>
                })}

            </>}

            {!account && <span><a href="#" onClick={e => {e.preventDefault(); setConnectIntent(true)}}>Connect</a> to view your configs</span>}

        </Grid.Unit>
    </Page>

}
