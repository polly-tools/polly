import copy from "copy-to-clipboard";
import styled from "styled-components";

const Copy = styled.a`
  line-height: 1em;
  display: inline-block;
  width: 1.1em;
  height: 1.1em;
  cursor: pointer;
  border: 1px solid ${props => props.theme.colors.primary};
  border-radius: 4px;
  transition: all 50ms ease-in-out;
  &:active {
    opacity: 0.5;
    transform: scale(0.9);
  }
  &:after {
    content: "+";
    display: block;
    position: relative;
    top: -0.1em;
    left: 0.15em;
  }
`;

function truncate(address){
  return address.slice(0, 6) + "..." + address.slice(-4);
}

export default function Address({address}){
  return <span>
    {truncate(address)} <Copy title="Copy to clipboard" onClick={() => copy(address)}/>
  </span>;
}
