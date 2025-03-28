import { GithubLink, Platforms, StyledPlatform, FooterContainer } from './styled';



const Footer = () => {
    return <FooterContainer>
    <h2>Available on all platforms</h2>
    <Platforms>
        <StyledPlatform src="/superpowered-universal-app/images/platforms/ios.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/android.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/macos.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/windows.svg" />
        <StyledPlatform src="/superpowered-universal-app/images/platforms/js.svg" />
    </Platforms>
    <GithubLink href="https://github.com/splice/superpowered-universal-app" target="_blank">LEARN MORE</GithubLink>
    
    </FooterContainer>
}

export default Footer;