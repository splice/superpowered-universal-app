import React, {useRef, useEffect} from 'react';
import { useTheme } from 'styled-components';
import { MeterContainer } from './styled';

const Meter = ({peaks, direction, width, height}) => {
    const canvasRef = useRef();
    const canvasContext = useRef();
    const theme = useTheme();
    const previousValue = useRef(0);

    const renderPeak = () => {
        if (canvasRef.current) {
            if (!canvasContext.current) {
                canvasContext.current  = canvasRef.current.getContext("2d");
                canvasContext.current.fillStyle = theme.palette.primary.main;
            }
            canvasContext.current.clearRect(0, 0, canvasRef.current.width, canvasRef.current.height);
            let nextValue;
            if (peaks.stereo > previousValue.current) {
                nextValue = peaks.stereo
            } else {
                nextValue = previousValue.current * 0.99;
            }
            if (direction === 'vertical') {
                canvasContext.current.fillRect(0, canvasRef.current.height, canvasRef.current.width, -canvasRef.current.height* nextValue);
            } else {
                canvasContext.current.fillRect(0, 0, canvasRef.current.width * nextValue, canvasRef.current.height);
            }
            previousValue.current = nextValue;
        }
        requestAnimationFrame(renderPeak);
    }; 
    useEffect(()=>{
        requestAnimationFrame(renderPeak)
    })

    return <MeterContainer width={width} height={height}>
        <canvas direction={direction} ref={canvasRef} width={width} height={height} />
    </MeterContainer>
}

export default Meter;