import Grid from "styled-components-grid";

export default function MetaInput() {
  return <Grid>
      <Grid.Unit size={1/5}>
        <select>
          <option>String</option>
          <option>Number</option>
          <option>Boolean</option>
          <option>Address</option>
        </select>
      </Grid.Unit>
      <Grid.Unit size={1/5}>
        <input type="text"/>
      </Grid.Unit>
      <Grid.Unit size={3/5}>
        <input type="text"/>
      </Grid.Unit>
    </Grid>
}
