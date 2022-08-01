import styled from 'styled-components';
import {chainToName, truncate} from 'base/utils';
import { InjectedConnector } from "@web3-react/injected-connector";
import { WalletConnectConnector } from "@web3-react/walletconnect-connector";
import { useWeb3React } from '@web3-react/core'
import { useEffect, useState } from 'react';
import {breakpoint} from 'styled-components-breakpoint';
import { debounce } from 'lodash';
import useError from '@hook/useError';
import { ethers } from 'ethers';
import useENS from '@hook/useENS';
import useEthNet from '@hook/useEthNet';

export const injected = new InjectedConnector({ supportedChainIds: [1, 4, 31337]});
export const wcConnector = new WalletConnectConnector({
  infuraId: process.env.NEXT_PUBLIC_INFURA_ID,
});


const Wrapper = styled.div`
  display: flex;
  justify-content: flex-start;
  font-size: 1em;
  position: relative;
`

const ConnectGroup = styled.div`
  transition: opacity 500ms ease-out, transform 150ms ease-out;
  position: absolute;
  top: -0.6em;
  right: 0;
  ${p => !p.$show && `
    transition: opacity 150ms ease-out, transform 500ms ease-out;

    transform: translate(100%);
    opacity: 0;
    pointer-events: none;
  `}
`

const Connect = styled.a`
  cursor: pointer;
  margin-right: 2vw;
  &:last-child {
    margin-right: 0;
  }

  ${breakpoint('sm', 'md')`
    margin-right: 4vw;
  `}
`

export function useWantToConnect(){

  const [wantToConnect, setWantToConnect] = useState(false);
  return {wantToConnect, setWantToConnect};

}

export default function ConnectButton({onActivate}) {
  
  const {activate, active, deactivate, account, library, chainId} = useWeb3React();
  const {wantToConnect, setWantToConnect} = useWantToConnect();
  const err = useError();
  const net = useEthNet();

  const {ENS, address, resolving, resolve} = useENS();
  const test = useENS('0x5090c4Fead5Be112b643BC75d61bF42339675448')

  useEffect(() => {
    if(account){
      resolve(account, library ? library : false);
    }
  }, [account])

  return (
    <Wrapper>
      
      <ConnectGroup $show={!wantToConnect && active}>
        <Connect onClick={deactivate}>
          Disconnect <small>({ENS && ENS}{(!ENS && account) && (truncate(account, 6, '...')+account.slice(-4))})</small>
        </Connect>
      </ConnectGroup>

      <ConnectGroup $show={!wantToConnect && !active}>
        <Connect onClick={() => setWantToConnect(true)}>
          Connect
        </Connect>
      </ConnectGroup>

      <ConnectGroup $show={wantToConnect}>
        <Connect
        onClick={() => {
          if(onActivate)
            onActivate()
          activate(injected);
          setWantToConnect(false)
        }}
      >
        <span>Metamask</span>
        </Connect>

        <Connect
        onClick={() => {
          if(onActivate)
            onActivate()
          activate(wcConnector);
          setWantToConnect(false)
        }}
      >
        <span>Walletconnect</span>
        </Connect>
      </ConnectGroup>

    </Wrapper>
    );
  }
  