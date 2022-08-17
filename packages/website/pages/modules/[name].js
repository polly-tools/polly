import useContract from "base/hooks/useContract"
import { usePolly } from "base/hooks/usePolly"
import { useRouter } from "next/dist/client/router";
import { useEffect, useState } from "react";
import Grid from "styled-components-grid";
import Page from "templates/Page";

function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function hyphenToCC(string){
    return capitalizeFirstLetter(string.replace(/-([a-z])/g, (m, s) => {
        return s.toUpperCase();
    }));
}

export default function Module({p}){

    const [module, setModule] = useState(-1);
    const {query} = useRouter();
    const polly = usePolly();
    
    async function fetchModule(){
        const name = hyphenToCC(query.name);
        const module = await polly.read('getModule', {name_: name, version_: 0}).then(res => res.result);
        setModule(module)
    }

    useEffect(() => {
        if(query.name)
            fetchModule();

    }, [query.name])

    return <Page header>
        {module && <Grid.Unit>
            <h1>{module.name}</h1>
            <h1>{module.implementation}</h1>
        </Grid.Unit>}
    </Page>

}