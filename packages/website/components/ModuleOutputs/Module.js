import Grid from "styled-components-grid";
import Link from "next/link";

export default function String({output, param, ...p}){

    return <Grid>
        <Grid.Unit size={1/2}>
        <h4>{param._string} {param._uint}</h4>
        Deployed at <Link href={`/module/${param._address}`}><a>{param._address}</a></Link>
        </Grid.Unit>
    </Grid>
}
