import { range } from "lodash";
import Grid from "styled-components-grid";

export default function Uint({input, module, ...p}){

    function handleChange(e){
        p.onChange(e.target.value);
    }

    let range = {};
    if(input.range){
      range = input.range;
    }

    return <div>
        <label>{input.name}</label><br/>
        <small>{input.description}</small>
        {input.options && <select onChange={handleChange}>
            {input.options.map((option, index) => <option key={index} value={option.value}>{option.label}</option>)}
        </select>}
        {!input.options && <input type="number" {...range} onKeyUp={handleChange}/>}
    </div>
}
