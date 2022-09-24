import { createGlobalStyle, ThemeProvider } from 'styled-components'
import {breakpoint} from 'styled-components-breakpoint';
import theme from 'base/style/theme';
import Web3, { utils } from "web3";
import { Web3ReactProvider, useWeb3React } from "@web3-react/core";
import { getProvider } from 'base/provider';
import { ErrorProvider } from '@hook/useError';
import ErrorMessage from 'components/ErrorMessage/ErrorMessage';
import {ethers} from 'ethers';
import { EthNetProvider } from '@hook/useEthNet';
import { ConnectIntent } from 'components/ConnectButton/ConnectButton';
import { useEffect } from 'react';

function getLibrary(provider){
  return new ethers.providers.Web3Provider(provider);
}


const GlobalStyle = createGlobalStyle`

  body {

    font-family: ${theme.fonts[0].family};
    font-size: 3.5vw;
    font-weight: ${theme.fonts[0].regular};
    letter-spacing: ${theme.fonts[0].letterSpacing};
    background-color: ${p => p.theme.colors.bg};
    color: ${theme.colors.text};
    margin: 0;
    padding: 0;
    display: flex;
    width: 100%;
    height: 100vh;

    * {
      box-sizing: border-box;
    }

    > div {
      width: 100%;
    }

    ${breakpoint('md')`
      font-size: 1.6vw;
    `}

    ${breakpoint('lg')`
      font-size: 1vw;
    `}
  }

  h1, h2, h3, h4, h5 {
    margin-top: 0;
    font-weight: ${p => p.theme.fonts[0].bold};
  }

  h1.compact, h2.compact, h3.compact, h4.compact, h5.compact {
    margin-bottom: 0;
  }

  h4, h5 {
    margin-bottom: 0;
  }

  p {
    margin: 0 0 20px 0;
  }

  a {
    color: inherit;
    &:hover {
      text-decoration: none;
    }
  }

  ol, li {
    padding: 0;
    margin: 0;
  }


  input[type="text"], input[type="number"], input[type="password"], input[type="email"]{

    border: 0px solid ${theme.colors.text};
    border-bottom-width: 2px;
    background-color: transparent;
    font-family: ${theme.fonts[0].family};
    font-size: inherit;
    padding: 1vw 0;
    color: inherit;
    width: 100%;
    box-sizing: border-box;

    ${breakpoint('sm', 'md')`
      padding: 2vw 0;
    `}
    border-radius: 0;

    &:focus {
      outline: 0;
    }
    &::placeholder {
      opacity: 0.5;
      color: ${theme.colors.text};
    }

  }

  select {
    border: 0px solid ${theme.colors.text};
    border-bottom-width: 2px;
    background-color: transparent;
    font-family: ${theme.fonts[0].family};
    font-size: inherit;
    padding: 1vw 0;
    color: inherit;
    width: 100%;
    box-sizing: border-box;
  }

  button {
    transition: all 150ms;
    background-color: ${theme.colors.emph2};
    padding: 1vw 2vw;
    cursor: pointer;
    ${breakpoint('sm', 'md')`
      padding: 2vw 3vw;
    `}
    border: none;
    /* box-shadow: 0px 0px 20px rgba(0,0,0,0.1); */
    color: ${theme.colors.text};
    font-family: ${theme.font};
    font-size: inherit;
    &:hover {
      background-color: ${theme.colors.emph1};
    }
    &:active {
      background-color: ${theme.colors.emph3};
      /* box-shadow: 0px 0px 10px rgba(0,0,0,0.1); */
    }
    margin-right: 2vw;
    &:last-child {
      margin-right: 0;
    }
  }

`


export default function App({ Component, pageProps }) {

  return (
        <ErrorProvider>
            <Web3ReactProvider getLibrary={getLibrary}>
              <EthNetProvider chainHex={process.env.NEXT_PUBLIC_NETWORK_HEX} chainID={process.env.NEXT_PUBLIC_NETWORK_ID}>
                <ThemeProvider theme={theme}>
                <ConnectIntent>
                  <ErrorMessage/>
                  <GlobalStyle />
                  <Component {...pageProps} />
                </ConnectIntent>
                </ThemeProvider>
              </EthNetProvider>
          </Web3ReactProvider>
       </ErrorProvider>
  )

}
