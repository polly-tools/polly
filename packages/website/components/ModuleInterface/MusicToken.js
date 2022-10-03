import { useModuleInterface } from ".";
import Tabs, {Tab} from "components/Tabs/Tabs";
import { useState } from "react";
import styled from "styled-components";

const Filters = styled.div`
  font-size: 0.8rem;
  display: flex;
  flex-direction: row;
  justify-content: right;
  width: 100%;
`

export function MusicTokenEdit(){

    const {address, module, setInput} = useModuleInterface();
    const [advanced, setAdvanced] = useState(false);

    return <>
      <Filters>
        <label>advanced</label>
        <input onChange={() => setAdvanced(!advanced)} type="checkbox"/>
      </Filters>
      <Tabs>
        <Tab title="Collection">
          This is where all collection settings are handled
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
