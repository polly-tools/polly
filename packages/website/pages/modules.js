import Page from 'templates/Page.js';
import Grid from 'styled-components-grid';
import useContract from 'base/hooks/useContract';
import pollyABI from '@polly-tools/core/abi/Polly.json';
import { useEffect, useState } from 'react';
import { useWeb3React } from '@web3-react/core';
import {paramCase} from 'param-case'
import Link from 'next/link'


import styled from 'styled-components';
import GridUnit from 'styled-components-grid/dist/cjs/mixins/gridUnit';

const ModuleCard = styled.a`
  display: block;
  width: 100%;
  color: #fff;
  border: 1px solid #eee;
  border-radius: 5px;
  padding: 10px;
  background: ${p => p.theme.colors.main};
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  text-decoration: none;
  &:hover {

  }
`

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
            <Grid>
            {modules.length > 0 && modules.map((module, index) => {
                return <Grid.Unit size={1/4} href={`/modules/${paramCase(module.name)}`} key={index}>
                  <Link href={`/modules/${paramCase(module.name)}`}>
                    <ModuleCard>
                      {module.name}
                    <br/>
                    <small>v{module.version} | {module.clonable ? 'CLONABLE' : 'READ-ONLY'}</small>
                    </ModuleCard>
                  </Link>
              </Grid.Unit>
              })}
            </Grid>
        </Grid.Unit>
    </Page>

}
