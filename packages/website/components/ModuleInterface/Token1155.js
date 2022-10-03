import ModuleInput from "components/ModuleInputs/ModuleInput";
import { useModuleInterface } from ".";


export function Token1155Edit(){

    const {address, module, setInput} = useModuleInterface();

    return <>

      <button>Create token</button>
    </>
}
