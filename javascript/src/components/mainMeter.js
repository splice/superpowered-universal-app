import React from 'react'
import styled from 'styled-components';
import Meter from '../components/meter';

const MainMeterContainer = styled.div`
    display: flex;
    justify-content: center;
    margin-top: 38px;
    background: white;
    height: 320px;
    border-radius: 4px;
`;

const MainMeter = ({onVolumeChange, peaks}) => {

    return <MainMeterContainer>
        <Meter direction={'vertical'} width={12} height={320} peaks={peaks}/>
    </MainMeterContainer>
}

export default MainMeter;