
import Slider from '@mui/material/Slider';

const CustomSlider = ({direction = 'horizontal', marks=[],  min = 0, max = 1, step = 0.01, defaultValue = 1, value, onChange}) => {
    const sliderStyles = direction === 'vertical'? {
        '& input[type="range"]': {
            WebkitAppearance: 'slider-vertical',
        },
        }: {};
    return <Slider
                sx={sliderStyles}
                orientation={direction}
                step={step}
                min={min}
                max={max}
                marks={marks}
                defaultValue={defaultValue}
                value={value}
                color="primary"
                // aria-label="Temperature"
                // onKeyDown={preventHorizontalKeyboardNavigation}
                onChange={(e)=>onChange(Number(e.target.value))}
            />
        
    
}

export default CustomSlider;