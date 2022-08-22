import getBaseUrl from "base/url";
import { useEffect, useState } from "react";

export default function Hello(p){

    const {module, config} = p;
    const [message, setMessage] = useState('');

    useEffect(() => {
        const message = await fetch(`${getBaseUrl()}/module/Hello/at/${module.instance}/sayHello`).then(res => res.json()).then(res => res.result);
        setMessage(message);
    }, [module]);

    return <div style={{marginBottom: '1em'}}>
        {message}
    </div>


}