import ConnectButton from "components/ConnectButton"
import Logo from "components/Logo/Logo"
import styled from "styled-components"
import Grid from "styled-components-grid"
import Link from "next/link"

const Wrapper = styled(Grid)`
width: 100vw;
${p => p.minHeight && `min-height ${p.minHeight};`};
padding: 5vw;
box-sizing: border-box;
justify-content: space-between;
`

const MenuItem = styled.span`
cursor: pointer;
white-space: pre;
margin-right: 1em;
&:last-child {
    margin-right: 0;
}
`

export default function Page({children, header, ...props}){
    return <Wrapper {...props}>
        {header && <Grid.Unit size={{sm: 1/1}} style={{justifyContent: 'space-between', display: 'flex', placeItems: 'center', marginBottom: '5em'}}>
        <Grid.Unit size={2/12}><Link href="/"><a><Logo/></a></Link></Grid.Unit>
        <Grid.Unit size={10/12} style={{textAlign: 'right', display: 'flex', justifyContent: 'right'}}>
            <MenuItem><Link href="/modules"><a>Modules</a></Link></MenuItem>
            <MenuItem>
                <Link href="/configs"><a>Configurations</a></Link>
            </MenuItem>
            <MenuItem><ConnectButton/></MenuItem>
        </Grid.Unit>
        </Grid.Unit>}
        {children}
    </Wrapper>
}