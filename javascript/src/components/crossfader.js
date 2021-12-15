import React from 'react'
import styled from 'styled-components';
import Slider from '../components/slider';

const CrossfaderContainer = styled.div`
    display: flex;
    justify-content: center;
`;

const Crossfader = ({onVolumeChange}) => {

    return <CrossfaderContainer>
        <Slider marks={[
            {
                value: 0,
                label: 'A',
            },
            {
                value: 0.5,
                label: '|',
            },
            {
                value: 1,
                label: 'B',
            }
        ]} 
        min={0}
        max={1}
        defaultValue={0.5}
            onChange={(v)=>onVolumeChange(v)} />
    </CrossfaderContainer>
}

export default Crossfader;