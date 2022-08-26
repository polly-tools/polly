import Grid from "styled-components-grid";
import {inputParam} from "@polly-os/utils/js/PollyConfigurator"

export default function String({input, module, ...p}){

    function handleChange(e){
        p.onChange(e.target.value);
    }

    return <div>
        <label>{input.name}</label><br/>
        <input type="text" onKeyUp={handleChange}/>
        <small>{input.description}</small>
        </div>
}