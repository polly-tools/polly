import { useWeb3React } from '@web3-react/core';
import { ethers } from 'ethers';
import React, { useState, useEffect } from 'react';

const EthNetCtx = React.createContext(false);

const createEthNet = ({chainID, ...p}) => {
    
    const web3 = useWeb3React();

    async function switchNet(){
        await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: ethers.utils.hexlify(parseInt(chainID))}],
        })
    }

    function isChainID(){
        return (web3.chainId == chainID);
    }

    return {chainID, isChainID, switchNet};
}


export const EthNetProvider = ({children, ...props}) => {
    const value = createEthNet(props);
    return <EthNetCtx.Provider value={value}>{children}</EthNetCtx.Provider>
};


export default function useEthNet() {
    const context = React.useContext(EthNetCtx)
    if (context === undefined) {
        throw new EthNet('useEthNet must be used within a EthNetProvider')
    }
    return context
}