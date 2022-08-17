import styled from "styled-components";
import { breakpoint } from "styled-components-breakpoint";

const Button = styled.button`
    
    ${p => p.expandOn && `
        ${breakpoint(...p.expandOn)`
            width: 100%!important;
        `}
    `};

    ${p => p.invertColors && `
        background-color: ${p.theme.colors.text}!important;
        color: ${p.theme.colors.bg}!important;
    `}

`

export default Button;