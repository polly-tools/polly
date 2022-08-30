import { useModuleInterface } from "./ModuleInterface";


export function MetaEdit(p){

    const {module, info, setInput} = useModuleInterface();
    const {address} = p;
    
    return <>
        <h5>Deployed at {address}</h5>
    </>
}