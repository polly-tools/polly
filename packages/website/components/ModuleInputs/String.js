import Grid from "styled-components-grid";
import {inputParam} from "@polly-os/utils/js/PollyConfigurator"

export default function String({input, module, ...p}){

    function handleChange(e){
        p.onChange(inputParam(e.target.value));
    }

    return <Grid>
        <Grid.Unit>
        <label>{input.name}</label>
        </Grid.Unit>
        <Grid.Unit size={1/2}>
        <input type="text" onKeyUp={handleChange}/>
        </Grid.Unit>
    </Grid>
}