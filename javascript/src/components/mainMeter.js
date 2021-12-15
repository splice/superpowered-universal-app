import React from 'react'
import Meter from '../components/meter';
import { CentralMeterContainer } from './styled';

const MainMeter = ({peaks}) => {
    return <CentralMeterContainer>
        <Meter direction={'vertical'} width={12} height={320} peaks={peaks}/>
    </CentralMeterContainer>
}

export default MainMeter;