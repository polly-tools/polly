import styled from 'styled-components';
import {breakpoint} from 'styled-components-breakpoint';
import Button from 'components/Button';

const Modal = styled.div`

position: fixed;
z-index: ${p => p.zIndex ? p.zIndex : '100'};
top: 0;
left:0;
right: 0;
bottom: 0;
width: 100vw;
height: 100vh;
background-color: ${p => p.theme.colors.modalBg};
display: flex;
flex-direction: column;
place-items: center;
justify-content: center;
opacity: 0;
pointer-events: none;
transition: opacity 200ms;

${p => p.show && `
    opacity: 1;
    pointer-events: all;
    backdrop-filter: blur(10px);
`}

`

export const ModalInner = styled.div`
padding: 1vw;
max-width: 800px;
${p => p.center && `
    display:flex;
    justify-content: center;
`}
${breakpoint('sm', 'md')`
    max-width: 100%;
`}

`


const Buttons = styled.div`

    padding: 2vw 0 0 0;
    display: flex;
    justify-content: ${p => p.position ? p.position : 'flex-end'};
    justify-items: ${p => p.position ? p.position : 'flex-end'};
    width: 100%;

`

export const ModalActions = function({actions, ...p}){

    return <Buttons {...p}>
        {actions && actions.map((action, index) => <Button key={index} invertColors={action.cta} onClick={action.callback}>{action.label}</Button>)}
    </Buttons>

}


export function Prompt({children, actions, ...p}){
    return <Modal {...p}>
        <ModalInner>
            {children}
            {actions && <ModalActions actions={actions}/>}
        </ModalInner>
    </Modal>
}

export default Modal;
