import { useModuleInterface } from ".";
import Tabs, {Tab} from "components/Tabs/Tabs";
import { useEffect, useState } from "react";
import styled from "styled-components";

const Filters = styled.div`
  font-size: 0.8rem;
  display: flex;
  flex-direction: row;
  justify-content: right;
  width: 100%;
`

const InputWrapper = styled.div`
  margin-bottom: 1rem;
`


const Input = ({
  label,
  onValueChange,
  type = "text",
  name,
  ...p
}) => {

  const [value, setValue] = useState(p.value);

  useEffect(() => {
    if(value)
      onValueChange(value, name, type);
  }, [value])

  if(type == "number") {
    return <InputWrapper>
      <label>{label}</label>
      <input type="number" value={value} onChange={(e) => setValue(e.target.value)} />
    </InputWrapper>
  }
  else if(type == "text") {
    return <InputWrapper>
      <label>{label}</label>
      <input type="text" value={value} onChange={(e) => setValue(e.target.value)} />
    </InputWrapper>
  }
  else if(type == "select") {
    return <InputWrapper>
      <label>{label}</label>
      <select value={value} onChange={(e) => setValue(e.target.value)}>
        {p.options.map((option) => <option value={option.value}>{option.label}</option>)}
      </select>
    </InputWrapper>
  }
  else if(type == 'boolean'){
    return <InputWrapper>
      <label>{label}</label>
      <input type="checkbox" checked={value} onChange={(e) => setValue(e.target.checked)} />
    </InputWrapper>
  }

}

const collection = [
  {
    name: "collection_name",
    label: "Collection name",
    type: "text"
  },
  {
    name: "collection_description",
    label: "Collection description",
    type: "text"
  }
]

export function MusicTokenEdit(){

    const {address, module, setInput} = useModuleInterface();
    const [advanced, setAdvanced] = useState(false);

    const [values, setValues] = useState({});

    function addValue(value, name, type){
      console.log(value, name, type)
    }

    function getValue(name, type){
      console.log('fetching value', name, type)
      console.log(module);
      return fetch(`/api/module/Meta/at/${module.params[1]._address}/getString`, {name_: name}).then((r) => r.json()).then(res => res.result);
    }

    return <>
      <Filters>
        <label>advanced</label>
        <input onChange={() => setAdvanced(!advanced)} type="checkbox"/>
      </Filters>
      <Tabs>
        <Tab title="Collection">
          {collection.map((input) => <Input {...input} value={() => getValue(input.name, input.type)} onValueChange={(value, name, type) => addValue(value, name, type)} />)}
        </Tab>
        <Tab title="Releases">
          This is where all releases are handled and created<br/>
          <button>New release</button>
        </Tab>
        {advanced &&
        <Tab title="Token1155">
          Deep level meta to
        </Tab>
        }
        {advanced &&
        <Tab title="Meta">
          Deep level access to the metadata of the collection
        </Tab>
        }
      </Tabs>

    </>
}
