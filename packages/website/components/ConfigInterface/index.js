
import Token721 from './Token721/Token721.js';


const interfaces = {
  Token721,
}


export default function ConfigInterface({config, module}){

  const Interface = interfaces[config.module];

  return <>

  {module && <Interface config={config}/>}
  {!module && <div>Loading...</div>}
  </>

}
