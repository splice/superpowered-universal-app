import MixerChannel from './mixerChannel.js';

const HEADROOM_DECIBEL = -3;
const headroom = Math.pow(10, HEADROOM_DECIBEL * 0.05);

class MixerEngine {

    constructor(superpoweredInstance, samplerate, numChannels) {
        this.Superpowered = superpoweredInstance;
        
        this.channels = new Array(numChannels);

        for (let channelIndex = 0; channelIndex < numChannels; channelIndex++) {
            this.channels[channelIndex] = new MixerChannel(this.Superpowered, samplerate);
        }

        this.crossfaderMixer = new this.Superpowered.StereoMixer();

        this.peak = 0;
        this.setCrossFaderPosition(0.5);
    }

    togglePlay() {
        this.channels[0].togglePlay(true);
        this.channels[1].togglePlay(false);
    }

    getPeak() {
        return this.peak;
    }

    setCrossFaderPosition(newValue) {
        this.crossFaderPosition = newValue;
        
        const leftGain = Math.cos((Math.PI / 2) * this.crossFaderPosition) * headroom;
        const rightGain = Math.cos((Math.PI / 2) * (1 - this.crossFaderPosition)) * headroom;

        this.crossfaderMixer.inputGain[0] = leftGain;
        this.crossfaderMixer.inputGain[1] = leftGain;
        this.crossfaderMixer.inputGain[2] = rightGain;
        this.crossfaderMixer.inputGain[3] = rightGain;
    }

    setTempo(newValue) {
        this.channels[0].setSyncToBPM(newValue);
        this.channels[1].setSyncToBPM(newValue);
    }

    setChannelVolume(channel, newVolume) {
        this.channels[channel].setVolume(newVolume);
    }

    getChannelPeak(channel) {
        return this.channels[channel].getPeak();
    }

    getChannelPitchShift() {
        return this.channels[0].getPitchShift();
    }

    setChannelPitchShift(channel, newValue) {
        this.channels[channel].setPitchShift(newValue);
    }

    setChannelFilterFrequencyPosition(channel, newValue) {
        this.channels[channel].setFilterFrequencyPosition(newValue);
    }

    setChannelRollEnabled(channel, beats) {
        this.channels[channel].setRollEnabled(beats);
    }

    setChannelRollDisable(channel) {
        this.channels[channel].setRollDisabled();
    }

    process(inputBuffer, outputBuffer, bufferSize, samplerate) {
        for (let channel = 0; channel < this.channels.length; channel++) {
            this.channels[channel].setSamplerate(samplerate);
            this.channels[channel].process(bufferSize);
        }

        this.crossfaderMixer.process(
            this.channels[0].channelOutputBuffer,
            this.channels[1].channelOutputBuffer,
            0,
            0,
            outputBuffer,
            bufferSize
        );

        this.channelAPeak = this.Superpowered.Peak(
            this.channels[0].channelOutputBuffer,
            bufferSize
        );
        this.channelBPeak = this.Superpowered.Peak(
            this.channels[1].channelOutputBuffer,
            bufferSize
        );
        this.outputPeak = this.Superpowered.Peak(
            outputBuffer,
            bufferSize
        );
    }

    destroy() {
        // First clean up the mixer channel instances
        for (let channelIndex = 0; channelIndex < this.channels.length; channelIndex++) {
            this.channels[channelIndex].destroy();
            
        }
        // Then the mixer insanc in this calss.
        this.crossfaderMixer.destroy();
    }
}

export default MixerEngine