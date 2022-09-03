import React, { useState, useEffect} from 'react';
import useModule from 'base/hooks/useModule.js';
import { parseParam } from '@polly-os/utils/js/Polly.js';

import * as Hello from './Hello.js';
import * as Meta from './Meta.js';

const interfaces = {
    ...Hello,
    ...Meta
}

function createModuleInterface(name, version){

    const {module, fetching, inputs, outputs} = useModule({
        name, version
    });

    const [userInputs, setUserInputs] = useState([]);

    function setUserInput(index, value){
        setUserInputs(userInputs => {
            const _new = [...userInputs];
            _new[index] = parseParam(value);
            return _new;
        })
    }

    return {name, version, fetching, module, inputs, outputs, userInputs, setUserInput};

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



export default function ModuleInterface({create}){

    const {name} = useModuleInterface();
    const iname = name + (create ? 'Create' : 'Edit');
    const Interface = interfaces[iname] ? interfaces[iname] : false;

    return <>{Interface && <Interface/>}</>

}
