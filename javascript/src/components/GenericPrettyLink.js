import React from 'react';
import styled from 'styled-components';
import GithubIcon from './GithubIcon';

const Wrapper = styled.a`
    background: ${props => props.background};
    border-radius: 15px;
    padding: 20px;
    display: flex;
    border: none;
    color: ${props => props.color};
    &:hover {
        transform: scale(1.01);
        color: ${props => props.hoverColor};
    }
    box-shadow: 10px 10px #e7e5e5;
    margin-bottom: 40px;
    max-width: max-content;
`;

const Meta = styled.div`
    display: flex;
    flex-direction: column;

`;

const ImageArea = styled.div`
margin-right: 10px;
`;

const Title = styled.span`
    font-size: 1.3rem;
    font-weight: bold;
    margin: 0;
    display: block;
    font-family: "Soehne",-apple-system,BlinkMacSystemFont,"Segoe UI","Roboto","Helvetica","Arial",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"
`;

const Subtitle = styled.span`
    margin-top: 0.3rem;
    margin-bottom: 0.1rem;
    font-size: 0.8rem;
    display: block;
    // font-weight: bold;
    color: ${props => props.color};
    font-family: "Soehne",-apple-system,BlinkMacSystemFont,"Segoe UI","Roboto","Helvetica","Arial",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"
`;

const Description = styled.p`
    margin-top: 0.3rem;
    
    // font-size: 0.8rem;
    // font-weight: bold;
    color: ${props => props.color};
    font-family: "Soehne",-apple-system,BlinkMacSystemFont,"Segoe UI","Roboto","Helvetica","Arial",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol"
`;

const Header = styled.div`
    background
`;

const GenericPrettyLink = ({title, 
    description, 
    href, 
    Icon = GithubIcon,
    background="black",
    titleColor="white",
    textColor="#a6a8ad",
    hoverColor="#1253FF"
}) => <Wrapper 
        background={background}
        hoverColor={hoverColor}
        color={titleColor}
        href={href}
    >
    <ImageArea backgroundColor={background}>
        <Icon />
    </ImageArea>
    
    <Meta>
    <Header>
    <Title>{title}</Title>
        <Subtitle color={titleColor}>{href}</Subtitle>
    </Header>
       
        {description && <Description color={textColor}>{description}</Description>}
    </Meta>
    
</Wrapper>

export default GenericPrettyLink;