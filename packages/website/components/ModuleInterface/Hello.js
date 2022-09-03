import ModuleInput from "components/ModuleInputs/ModuleInput";
import { useEffect } from "react";
import { useModuleInterface } from "./ModuleInterface";

export function HelloCreate(p){

    const {module, inputs, setUserInput} = useModuleInterface();

    return <>
        {inputs && inputs.map((input, index) => <ModuleInput key={index} input={input} onChange={(value) => setUserInput(index, value)} />)}
    </>
}

export function HelloEdit(p){
    return <div style={{marginBottom: '1em'}}>
        HelloEdit
    </div>
}
