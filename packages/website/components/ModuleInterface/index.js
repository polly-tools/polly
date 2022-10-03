import React, { useState, useEffect} from 'react';
import useModule from 'base/hooks/useModule.js';
import { parseParam } from '@polly-os/utils/js/Polly.js';
import ModuleInput from 'components/ModuleInputs/ModuleInput.js';

import * as Hello from './Hello.js';
import * as Meta from './Meta.js';
import * as Token1155 from './Token1155.js';

const interfaces = {
    ...Hello,
    ...Meta,
    ...Token1155
}

const defaultInterfaces = {
  Create: () => {
    const {module, inputs, setUserInput} = useModuleInterface();
    return <>
      {inputs && inputs.map((input, index) => <ModuleInput key={index} input={input} onChange={(value) => setUserInput(index, value)} />)}
    </>
  }
}

function createModuleInterface(address, name, version){

    const module = useModule({
      address, name, version
    });


    const [userInputs, setUserInputs] = useState([]);

    function setUserInput(index, value){
        setUserInputs(userInputs => {
            const _new = [...userInputs];
            _new[index] = parseParam(value);
            return _new;
        })
    }

    return {...module, userInputs, setUserInput};

}

const ModuleInterfaceCtx = React.createContext();

export const ModuleInterfaceProvider = ({children, ...props}) => {
  const moduleInterface = createModuleInterface(props.address, props.name, props.version);
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

    const {module} = useModuleInterface();
    const iname = module.name + (create ? 'Create' : 'Edit');
    const Interface = interfaces[iname] ? interfaces[iname] : defaultInterfaces[create ? 'Create' : 'Edit'];

    return <>{Interface && <Interface/>}</>

}
