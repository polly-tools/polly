import Tabs, {Tab} from "components/Tabs/Tabs"
import useModule from "base/hooks/useModule";
import Aux from './Aux.js';
import Meta from './Meta.js';

export default function Token721({config}){

  const token721 = useModule({
    address: config.params[0]._address,
  });

  const meta = useModule({
    address: config.params[1]._address,
  });




  return <div>
    {(token721.fetching || meta.fetching)
    ?
    <div>Loading...</div>
    :
    <Tabs>
      <Tab title="Tokens">

      </Tab>
      <Tab title="Meta">
        <Meta config={config} token721={token721} meta={meta}/>
      </Tab>
      <Tab title="Aux">
        <Aux config={config} token721={token721} meta={meta}/>
      </Tab>
    </Tabs>
  }
  </div>
}
