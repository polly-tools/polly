import copy from "copy-to-clipboard";
import styled from "styled-components";

const Copy = styled.span`
  cursor: pointer;
  &:active {
    opacity: 0.5;
  }
`;

export default function Address({address, copyEnabled}){
  return <span>
    {address} <Copy onClick={() => copy(address)}>copy</Copy>
  </span>;
}
