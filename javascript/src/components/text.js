import styled from 'styled-components';

const StyledPlatform = styled.img`
    height: 40px;
    margin: 10px;
    max-width: 50px;
`;


const Platforms = styled.div`
    margin-bottom: 20px;
`;

const GithubLink = styled.a`
    background: #1253FF;
    padding: 10px 20px;
    border-radius: 15px;
    border: none;
    color: white;
    text-decoration: none;
    display: inline-block;
    margin-bottom: 10px;
    font-weight: 500;
`;

const Text = ({}) => {
   
    return <div>
    <h2>Available on all platforms</h2>
    <Platforms>
        <StyledPlatform src="/superpowered-universal-app/images/platforms/ios.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/android.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/macos.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/windows.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/js.svg" />
    </Platforms>
    <GithubLink href="https://github.com/splice/superpowered-universal-app" target="_blank">LEARN MORE</GithubLink>
    </div>
}

export default Text;