import React, { useState } from 'react'
import styled from 'styled-components';
import Meter from '../components/meter';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import ButtonGroup from '@mui/material/ButtonGroup';

import Slider from '../components/slider';

const ChannelContainer = styled.div`
    margin: 0 10px;
    padding: 10px;
    border-radius: 15px;
    background: #ffffff;
    border: 1px solid #1253FF;
`;


const FilterRollContainer= styled.div`
    display: flex;
    flex-direction: column;
    justify-content: space-between;
`;

const FlexRowSpread = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    flex-grow: 1;
`;

const ChannelLabel = styled.div`
    font-weight: 500;
    margin-bottom: 10px;
    background: white;
    border-radius: 8px;
`;

const ControlLabel = styled.div`
    color: #384552;
    font-weight: 500;
    margin: 5px 0;
    font-size:12px;
`;


const Channel = ({peaks, label, mixerEngineChannel, onVolumeChange, onFilterChange, onRollChange, onPitchChange, flip = false}) => {

    const [roll, setRoll] = useState(false);
    const [pitch, setPitch] = useState(0);

    const changeRoll = (newValue) => {
        if (newValue === roll) {
            setRoll(false);
            onRollChange(false)
        } else {
            setRoll(newValue);
            onRollChange(newValue)
        }
        
    }

    const changePitch = (newValue) => {
        if (newValue === -1 && (pitch > -12)) {
            setPitch(pitch - 1);
            onPitchChange(pitch - 1)
        } else if (newValue === 1 && (pitch < 12)) {
            setPitch(pitch + 1);
            onPitchChange(pitch + 1)
        } else {
            setPitch(0);
            onPitchChange(0)
        }
        
    }

    const renderRoll = () => {
        return <>
        <Button size="small" disableElevation variant={roll === 2 ? 'contained':'outlined'} onClick={()=>changeRoll(2)} className={roll === 2 ? 'active':''}>2</Button>
        <Button size="small" disableElevation  variant={roll === 1 ? 'contained':'outlined'} onClick={()=>changeRoll(1)} className={roll === 1 ? 'active':''}>1</Button>
        <Button size="small" disableElevation variant={roll === 0.5 ? 'contained':'outlined'} onClick={()=>changeRoll(0.5)} className={roll === 0.5 ? 'active':''}>1/2</Button>
        <Button size="small" disableElevation variant={roll === 0.25 ? 'contained':'outlined'} onClick={()=>changeRoll(0.25)} className={roll === 0.25 ? 'active':''}>1/4</Button>
        </>
    }

    const renderFiltersweep = () => {
        return <Box sx={{height: '120px'}}>
        <Slider 
            min={-20000}
            max={20000}
            step={1}
            defaultValue={0}
            onChange={(v)=>onFilterChange(v)}
            direction="vertical"
        />
    </Box>
    }
    const renderFilterRoll = () => {
        return <FilterRollContainer>

            <ControlLabel>ROLL</ControlLabel>

            <ButtonGroup
                orientation="vertical"
                aria-label="vertical contained button group"
            >
                {renderRoll()}
            </ButtonGroup>

            <ControlLabel>HP</ControlLabel>
            {renderFiltersweep()}
            <ControlLabel>LP</ControlLabel>

    </FilterRollContainer>
    }

    return <ChannelContainer>

        <ChannelLabel>{label}</ChannelLabel>

        <FlexRowSpread>
            {!flip && <FlexRowSpread>
                {renderFilterRoll()}
                <Box sx={{height: 320}}>
                <Slider 
                    onChange={(v)=>onVolumeChange(v)}
                    direction="vertical"
                />
                    </Box>
                
                <Meter direction="vertical" height={320} width={6} peaks={peaks}/>
            </FlexRowSpread>}
            {flip && <FlexRowSpread>
                <Meter direction="vertical" height={320} width={6} peaks={peaks}/>
                <Box sx={{height: 320}}>
                <Slider 
                    onChange={(v)=>onVolumeChange(v)}
                    direction="vertical"
                />
                </Box>
                {renderFilterRoll()}
            </FlexRowSpread>}
        </FlexRowSpread>
        <Box sx={{marginTop: '20px'}}>
        <ButtonGroup variant="outlined">
            <Button size="small" disableElevation onClick={()=>changePitch(-1)}>-1</Button>
            <Button size="small" onClick={()=>changePitch(0)} disableElevation >{pitch}</Button>
            <Button size="small" disableElevation  onClick={()=>changePitch(1)}>+1</Button>
        </ButtonGroup>
            </Box>
        
        <ControlLabel>PITCH</ControlLabel>
        
    </ChannelContainer>
}

export default Channel;