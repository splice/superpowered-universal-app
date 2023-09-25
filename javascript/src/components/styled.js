import styled from 'styled-components';

export const MeterContainer = styled.div`
    border: 1px solid ${props => props.theme.palette.primary.main};
    border-radius: 4px;
    flex-grow: 0;
    height: ${(props) => props.height}px;
`;

export const CentralMeterContainer = styled.div`
    display: flex;
    justify-content: center;
    margin-top: 38px;
    background: white;
    height: 320px;
    border-radius: 4px;
`;

export const StyledPlatform = styled.img`
    height: 40px;
    margin: 10px;
    max-width: 50px;
`;

export const Platforms = styled.div`
    margin-bottom: 20px;
`;

export const GithubLink = styled.a`
    background: ${props => props.theme.palette.primary.main};
    padding: 10px 20px;
    border-radius: 15px;
    border: none;
    color: white;
    text-decoration: none;
    display: inline-block;
    margin-bottom: 10px;
    font-weight: 500;
`;

export const CrossfaderContainer = styled.div`
    display: flex;
    justify-content: center;
`;

export const MixerContainer = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  max-width: 500px;
  margin: 0 10px 20px 10px;
  padding: 10px;
  border: 1px solid ${props => props.theme.palette.primary.main};
  border-radius: 15px;
  background: url(${props => props.$backgroundUrl});
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center center;
  box-shadow: 10px 10px #e7e5e5;
`;

export const ChannelBank = styled.div`
  display: flex;
  justify-content: center;
  margin-bottom: 10px;
`;

export const Logo = styled.img`
  margin: 10px 0;
`;


export const ChannelContainer = styled.div`
    margin: 0 10px;
    padding: 10px;
    border-radius: 15px;
    background: #ffffff;
    border: 1px solid ${props => props.theme.palette.primary.main};
`;


export const FilterRollContainer= styled.div`
    display: flex;
    flex-direction: column;
    justify-content: space-between;
`;

export const FlexRowSpread = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    flex-grow: 1;
`;

export const ChannelLabel = styled.div`
    font-weight: 500;
    margin-bottom: 10px;
    background: white;
    border-radius: 8px;
`;

export const ControlLabel = styled.div`
    color: #384552;
    font-weight: 500;
    margin: 5px 0;
    font-size:12px;
`;