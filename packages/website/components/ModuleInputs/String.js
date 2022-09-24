import Grid from "styled-components-grid";

export default function String({input, module, ...p}){

    function handleChange(e){
        p.onChange(e.target.value);
    }

    return <div>
        <label>{input.name}</label><br/>
        {input.values.length > 0 && <select onChange={handleChange}>
            {input.values.map((value, index) => <option key={index} value={value.value}>{value.label}</option>)}
        </select>}
        {input.values.length == 0 && <><input type="text" onKeyUp={handleChange}/>
          <small>{input.description}</small>
        </>
        }
    </div>
}
