import Grid from "styled-components-grid";
import {inputParam} from "@polly-os/utils/js/PollyConfigurator"

export default function String({input, module, ...p}){

    function handleChange(e){
        p.onChange(inputParam(e.target.value));
    }

    return <Grid>
        <Grid.Unit>
        </Grid.Unit>
        <Grid.Unit size={1/2}>
        <label>{input.name}</label><br/>
        <input type="text" onKeyUp={handleChange}/>
        <small>{input.description}</small>
        </Grid.Unit>
    </Grid>
}