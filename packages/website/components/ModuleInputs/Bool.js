import Grid from "styled-components-grid";

export default function Bool({input, module, ...p}){

    function handleChange(e){
        p.onChange(e.target.value);
    }

    return <div>
        <label>{input.name}</label><br/>
        <small>{input.description}</small>
        <input type="checkbox" onChange={handleChange}/>
    </div>
}
