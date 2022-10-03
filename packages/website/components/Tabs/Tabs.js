import styled from "styled-components";
import React, { useState } from "react";
const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
`;


export const Tab = (p) => {
  return null;
}


const TabTitles = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: left;
  align-items: center;
  margin-bottom: 1rem;
  border-bottom: 1px solid #eaeaea;
  padding-bottom: 1rem;
  width: 100%;
  overflow-x: auto;
  overflow-y: hidden;
  white-space: nowrap;
  -webkit-overflow-scrolling: touch;
  -ms-overflow-style: -ms-autohiding-scrollbar;
  scrollbar-width: none;
  &::-webkit-scrollbar {
    display: none;
  }
`;


const TabTitle = styled.div`
  cursor: pointer;
  padding: 0.5rem 1rem;
  margin-right: 1rem;
  border-radius: 0.5rem;
  font-size: 0.8rem;
  font-weight: 500;
  color: ${p => p.theme.colors.main};
  transition: all 0.2s ease-in-out;
  &:hover {
    background: #f5f5f5;
  }
  &.active {
    color: white;
    background: ${p => p.theme.colors.main};
  }
`;

const TabContent = styled.div`
  display: block;
`;




export default function Tabs({defaultTab, ...props}){

  const [tab, setTab] = useState(defaultTab || 0);
  const children = React.Children.toArray(props.children);
  const tabs = children.filter(c => c.type === Tab);
  return <Wrapper>

    <TabTitles>
      {tabs.map((t, i) => <TabTitle key={i} onClick={() => setTab(i)} className={i === tab ? 'active' : ''}>{t.props.title}</TabTitle>)}
    </TabTitles>
    <TabContent>
      {tabs && tabs[tab]?.props.children}
    </TabContent>
  </Wrapper>
}
