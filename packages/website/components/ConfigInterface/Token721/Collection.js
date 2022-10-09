import { useEffect, useState} from "react";
import Button from "components/Button";
import Grid from "styled-components-grid";
import MetaInput from "../MetaInput";

export default function Collection(){

  const [metaInputs, setMetaInputs] = useState([]);

  function addMetaInput(){
    setMetaInputs([...metaInputs, {key: "", value: ""}]);
  }

  function setMetaInput(index, value){
    metaInputs[index] = value;
    setMetaInputs([...metaInputs]);
  }

  useEffect(() => {
    console.log("metaInputs", metaInputs);
  }, [metaInputs]);

  return <div>
    <Button onClick={() => addMetaInput()}>Add meta value</Button>
    <Grid>
      <Grid.Unit size={1/5}>
        <div>Type</div>
      </Grid.Unit>
      <Grid.Unit size={1/5}>
        <div>Key</div>
      </Grid.Unit>
      <Grid.Unit size={3/5}>
        <div>Value</div>
      </Grid.Unit>
    </Grid>
    {metaInputs.map((mi, index) => <MetaInput key={index} metaKey={mi.key} metaValue={mi.value} onValueChange={value => setMetaInput(index, value)} />)}
  </div>
}
