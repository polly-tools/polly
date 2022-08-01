import styled, {keyframes} from 'styled-components';
import Grid from 'styled-components-grid';
import content, {open, extendable, permanent} from 'base/content/index';
import { useState } from 'react';

const fadeIn = keyframes`
    from {
        transform: scale(0.85) rotate(-20deg);
        opacity: 0;
    }
    to {
        transform: scale(1) rotate(0deg);
        opacity: 1;
    }
`

const Wrapper = styled(Grid)`
width: 100vw;
min-height: 100vh;
place-items: top;
padding: 5vw;
justify-content: space-between;
box-sizing: border-box;
`

const Logo = styled.img`
    max-width: 100%;
    height: auto;
    animation: ${fadeIn} 0.5s;
`


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

export default function Home(props){
    return <Wrapper>
            <Grid.Unit size={{sm: 1/1, md: 2/12}} style={{marginBottom: '7em'}}>
                <Logo src='/img/logo.png'/>
            </Grid.Unit>
            <Grid.Unit size={{sm: 1/1, md: 8/12}} style={{marginBottom: '7em'}}>
                <h2>
                    {content}
                </h2>
            </Grid.Unit>
            <Grid.Unit size={1/1} style={{alignSelf: 'end'}}>
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
    </Wrapper>
}

export async function getStaticProps(){
    
    return {
        props: {}
    }
}