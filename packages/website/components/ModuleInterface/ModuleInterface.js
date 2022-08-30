import React, { useState, useEffect} from 'react';
import useModule from 'base/hooks/useModule.js';
import { inputParam } from '@polly-os/utils/js/PollyConfigurator.js';

import * as Hello from './Hello.js';
import * as Meta from './Meta.js';

const interfaces = {
    ...Hello,
    ...Meta
}

function createModuleInterface(name, version){
    
    const {module, fetching, info} = useModule({
        name, version
    });
    const [inputs, setInputs] = useState([]);

    function setInput(index, value){
        setInputs(inputs => {
            const _new = [...inputs];
            _new[index] = inputParam(value);
            return _new;
        })
    }

    return {name, version, fetching, module, info, inputs, setInput};
    
}

const ModuleInterfaceCtx = React.createContext();

export const ModuleInterfaceProvider = ({children, ...props}) => {
    const moduleInterface = createModuleInterface(props.name, props.version);
    return <ModuleInterfaceCtx.Provider value={moduleInterface}>{children}</ModuleInterfaceCtx.Provider>
};


export function useModuleInterface() {
    const context = React.useContext(ModuleInterfaceCtx)
    if (context === undefined) {
        throw new Error('useModuleInterface must be used within a ModuleInterfaceProvider')
    }
    return context
}



export default function ModuleInterface({create, ...p}){

    const {name} = useModuleInterface();
    const iname = name + (create ? 'Create' : 'Edit');
    const Interface = interfaces[iname] ? interfaces[iname] : false;
    
    return <>{Interface && <Interface {...p}/>}</>
    
}