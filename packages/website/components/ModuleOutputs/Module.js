import Grid from "styled-components-grid";

export default function String({output, param, ...p}){

    return <Grid>
        <Grid.Unit size={1/2}>
        <h5>Deployed at {param._address}</h5>
        </Grid.Unit>
    </Grid>
}
