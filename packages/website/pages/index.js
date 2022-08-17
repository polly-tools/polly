import styled, {keyframes} from 'styled-components';
import Grid from 'styled-components-grid';
import content, {tag, open, extendable, permanent} from 'base/content/index';
import { useState } from 'react';
import Page from 'templates/Page';
import Logo from 'components/Logo/Logo';
import ConnectButton from 'components/ConnectButton';
import Link from "next/link"


const FoldOut = styled(({title, index, children, ...p}) => {

    const [open, setOpen] = useState();

    return <Grid {...p}>
        <Grid.Unit size={{sm: 1/1, md: 4/12}} onClick={() => setOpen(!open)}><span>({index})</span> {title}</Grid.Unit>
        <Grid.Unit size={{sm: 1/1, md: 8/12}}>
            {children}
        </Grid.Unit>
    </Grid>

})`

    width: 100%;
    border: 0px solid ${p => p.theme.colors.main};
    border-top-width: 1px;
    height: auto;
    padding: 1em 0;

    &:last-of-type {
        border-bottom-width: 1px;
    }
    
`

const Action = styled.div`
    margin-bottom: 1em;
    display: flex;
    flex-direction: column;
`

export default function Home(props){
    return <Page minHeight="100%">
            <Grid.Unit size={{sm: 1/1, md: 2/12}} style={{marginBottom: '7em'}}>
                <Logo src='/img/logo.png'/>
            </Grid.Unit>
            <Grid.Unit size={{sm: 1/1, md: 8/12}} style={{marginBottom: '7em'}}>
                <h2>
                    {tag}
                </h2>
            </Grid.Unit>
            

            <Grid.Unit size={1/3}>

                <Action>
                    <ConnectButton/>
                    <small>Connect your wallet to interact with Polly</small>
                </Action>


                <Action>
                    <Link href="/modules"><a>Modules</a></Link>
                    <small>See all available modules in Polly</small>
                </Action>

                <Action>
                    <Link href="/configs"><a>Configurations</a></Link>
                    <small>Review your configurations</small>
                </Action>


             </Grid.Unit>
            
            <Grid.Unit size={1/1} style={{alignSelf: 'end', marginBottom: '5em'}}>
                <FoldOut index={1} title="Open">
                        {open}
                </FoldOut>
                <FoldOut index={2} title="Extendable">
                        {extendable}
                </FoldOut>
                <FoldOut index={3} title="Permanent">
                        {permanent}
                </FoldOut>
            </Grid.Unit>


            <Grid.Unit size={1/1} style={{alignSelf: 'end'}}>
                {content}
            </Grid.Unit>
    </Page>
}

export async function getStaticProps(){
    
    return {
        props: {}
    }
}