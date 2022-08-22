import styled, {keyframes} from 'styled-components';

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

const Logo = styled(({...p}) => <img src='/img/logo.png' {...p}/>)`
    max-width: 100%;
    height: auto;
    animation: ${fadeIn} 0.5s;
`

export default Logo;