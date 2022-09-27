import String from './String.js';
import Uint from './Uint.js';
import Address from './Address.js';

export default function ModuleInput(p){
    return <div style={{marginBottom: '1em'}}>
        {p.input.type === 'string' && <String {...p}/>}
        {p.input.type === 'uint' && <Uint {...p}/>}
        {p.input.type === 'address' && <Address {...p}/>}
        {p.input.type === 'bool' && <Bool {...p}/>}
        </div>

}
