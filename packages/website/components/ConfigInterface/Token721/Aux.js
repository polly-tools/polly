import { useEffect, useRef, useState} from "react";
import Button from "components/Button";
import Grid from "styled-components-grid";
import _ from "lodash";
import useContract from "base/hooks/useContract";
import token721_abi from "@polly-tools/core/abi/Token721.json";
import Address from "components/Address";

const avail_hooks = [
  "beforeCreateToken",
  "afterCreateToken",
  "beforeMint721",
  "afterMint721",
  "tokenImage",
  "tokenURI",
  "contractURI",
  "royaltyInfo"
]


export default function Aux(p){

  const {config, token721, meta} = p;
  const [hooks, setHooks] = useState(false);

  const token721_contract = useContract({
    address: token721.address,
    abi: token721_abi,
    endpoint: `/api/modules/Token721/at/${token721.address}/`
  });

  async function fetchHooks(){

    const _hooks = {};
    await Promise.all(avail_hooks.map(hook => {
      return fetch(`/api/module/${config.module}/at/${token721.address}/addressForHook?hook_=${hook}&version=${config.version}`).then(res => res.json()).then(res => {
        _hooks[hook] = res.result !== '0x0000000000000000000000000000000000000000' ? res.result : false;
      })
    }))
    setHooks(_hooks);
  }

  useEffect(() => {
    fetchHooks();
  }, [])


  async function handleAddAux(aux){
    console.log('handleAddAux', aux);
    await token721_contract.write("addAux", {auxs_: [aux]});
  }

  const aux_ref = useRef();

  return <div>

    <p>
    An aux contract is a contract that changes the behaviour of the token in some way. For example, a token can be made to be non-transferable by using an aux contract.
    </p>

    <p>
    Add a new aux contract:
    <Grid>
      <Grid.Unit size={3/4}>
        <input type="text" placeholder="Aux address" ref={aux_ref}/>
      </Grid.Unit>
      <Grid.Unit size={1/4}>
        <Button onClick={() => handleAddAux(aux_ref.current.value)}>
          Add aux contract
        </Button>
      </Grid.Unit>
    </Grid>
    </p>

    <p>
      This is a list of the available hooks in this configuration and their aux addresses.

      <ul>
        {avail_hooks.map(hook =>
          <li>{hook}: {hooks[hook] && <Address address={hooks[hook]}/>}</li>
        )}
      </ul>
    </p>

  </div>

}
