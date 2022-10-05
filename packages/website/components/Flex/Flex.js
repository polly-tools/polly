import styled from "styled-components";

const Flex = styled.div`
  display: flex;
  flex-direction: ${p => p.direction || "row"};
  justify-content: ${p => p.justify || "flex-start"};
  align-items: ${p => p.align || "stretch"};
  flex-wrap: ${p => p.wrap || "nowrap"};
  flex: ${p => p.flex || "0 1 auto"};
  margin: ${p => p.margin || "0"};
  padding: ${p => p.padding || "0"};
  width: ${p => p.width || "auto"};
  height: ${p => p.height || "auto"};
`;


export default Flex;
