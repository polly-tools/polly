import { useModuleInterface } from "./ModuleInterface";

export function MetaCreate(p){
    
    const {module, info} = useModuleInterface();

    return <>
        {info && <>
            {info.inputs.map()}
        </>}
    </>
}

export function MetaEdit(p){
    return <div style={{marginBottom: '1em'}}>
        MetaEdit
    </div>
}