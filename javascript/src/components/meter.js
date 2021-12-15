import React, {useRef, useEffect} from 'react';
import styled from 'styled-components';


const MeterContainer = styled.div`
    border: 1px solid #a4b9fa;
    border-radius: 4px;
    flex-grow: 0;
    height: ${(props) => props.height}px;
`;

const fillColor = '#1253FF';

const Meter = ({peaks, direction, width, height}) => {

    const canvasRef = useRef();
    const canvasContext = useRef();

    let previousValue = 0;

    const renderPeak = () => {
        if (canvasRef.current) {
            if (!canvasContext.current) {
                canvasContext.current  = canvasRef.current.getContext("2d");
                canvasContext.current.fillStyle = fillColor;
            }
            canvasContext.current.clearRect(0, 0, canvasRef.current.width, canvasRef.current.height);
            let nextValue;
            if (peaks.stereo > previousValue) {
                nextValue = peaks.stereo
            } else {
                nextValue = previousValue * 0.99;
            }
            if (direction === 'vertical') {
                canvasContext.current.fillRect(0, canvasRef.current.height, canvasRef.current.width, -canvasRef.current.height* nextValue);
            } else {
                canvasContext.current.fillRect(0, 0, canvasRef.current.width * nextValue, canvasRef.current.height);
            }
            previousValue = nextValue;
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