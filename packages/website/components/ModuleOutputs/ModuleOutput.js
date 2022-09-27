import Module from './Module.js';

export default function ModuleOutput(p){

    const {output, param} = p;

    return <div style={{marginBottom: '1em'}}>

        <h4>{output.name}</h4>
        {(output.type) === 'module' && <Module {...p}/>}

        </div>

}
