import String from './String.js';

export default function ModuleInput(p){
    return <div style={{marginBottom: '1em'}}>
        {p.input.type === 'string' && <String {...p}/>}
        </div>

}