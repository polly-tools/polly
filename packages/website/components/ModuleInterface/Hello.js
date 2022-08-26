import ModuleInput from "components/ModuleInputs/ModuleInput";
import { useModuleInterface } from "./ModuleInterface";

export function HelloCreate(p){
    
    const {module, info, setInput} = useModuleInterface();
    return <>
        {info && info.inputs.map((input, index) => <ModuleInput key={index} input={input} onChange={(value) => setInput(index, value)} />)}
    </>
}

export function HelloEdit(p){
    return <div style={{marginBottom: '1em'}}>
        HelloEdit
    </div>
}