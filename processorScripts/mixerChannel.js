class MixerChannel {

    // We pass he superpowered library and sample rate in from the MixerEngine class (whcih passes it on from the AudioWorkletProcessorScript)
    // This also differs slightly from the C++ implemenation of MixerChannel as we ned to handle async loading from the web and not the file system
    constructor(superpoweredInstance, samplerate) {
        this.Superpowered = superpoweredInstance;

        this.channelInputBuffer = new this.Superpowered.Float32Buffer(4096);
        this.channelOutputPreGainBuffer = new this.Superpowered.Float32Buffer(4096);
        this.channelOutputBuffer = new this.Superpowered.Float32Buffer(4096);

        this.peak = 0;
        this.volume = 1;

        this.player = new this.Superpowered.AdvancedAudioPlayer(
            samplerate,
            2,
            2,
            0,
            0.501,
            2,
            false
        );

        this.roll = new this.Superpowered.Roll(
            samplerate,
            samplerate
        );
        this.roll.wet = 1;
        this.roll.enabled = false;

        this.lowpassFilter = new this.Superpowered.Filter(
            this.Superpowered.Filter.Resonant_Lowpass, // The initial filter type
            samplerate // initial sample rate
        );
        this.lowpassFilter.octave = 2;
        this.lowpassFilter.resonance = 0.05;
        this.lowpassFilter.enabled = false;

        this.hipassFilter = new this.Superpowered.Filter(
            this.Superpowered.Filter.Resonant_Highpass, // The initial filter type
            samplerate // initial sample rate
        );
        this.hipassFilter.octave = 2;
        this.hipassFilter.resonance = 0.05;
        this.hipassFilter.enabled = false;
    }

    // Handle async loading of decoded audio buffers from the web
    loadBuffer(buffer, assetDefinition) {
        this.player.openMemory(this.Superpowered.arrayBufferToWASM(buffer), false, false);
        this.assetLoaded = true;
        this.player.originalBPM = assetDefinition.originalBPM;
        this.player.firstBeatMs = assetDefinition.firstBeatMs;
    }

    togglePlay(isMaster) {
        if (!this.playing) {
            if (isMaster) {
                this.player.play()
            } else {
                this.player.playSynchronized();
            }
            this.playing = true;
        } else {
            this.player.pause();
            this.playing = false;
        }
    }

    setVolume(newVolume) {
        this.volume = newVolume;
    }

    getPeak() {
        return this.peak;
    }

    getPitchShift() {
        return this.player.pitchShiftCents/100;
    }

    setPitchShift(newValue) {
        this.player.pitchShiftCents = newValue * 100;
    }

    getIsLoaded() {
        return this.assetLoaded;
    }

    configure(originalBPM, firstBeatMs) {
        this.player.originalBPM = originalBPM;
        this.player.firstBeatMs = firstBeatMs;
        this.player.syncMode = this.Superpowered.AdvancedAudioPlayer.SyncMode_TempoAndBeat;
        this.player.setPosition(this.player.firstBeatMs, false, false);
    }

    getCurrentBPM() {
        return this.player.getCurrentBpm();
    }

    setSyncToBPM(bpm) {
        this.player.syncToBpm = bpm;
        this.roll.bpm = bpm;
    }

    setFilterFrequencyPosition(value) {
        if (value < -20) {
            this.lowpassFilter.frequency = 20020 + value;
            this.lowpassFilter.enabled = true;
            this.hipassFilter.enabled = false;
        } else if (value > 20) {
            this.hipassFilter.frequency = value;
            this.lowpassFilter.enabled = false;
            this.hipassFilter.enabled = true;
        } else {
            this.lowpassFilter.enabled = false;
            this.hipassFilter.enabled = false;
        }
    }

    setRollEnabled(beats) {
        this.roll.beats = beats;
        this.roll.enabled = true;
    }

    setRollDisabled() {
        this.roll.enabled = false;
    }

    process(bufferSize) {

        // Generate player buffers (or silence)
        if (!this.player.processStereo(this.channelOutputBuffer.pointer, false, bufferSize, 1)) {
            for (let n = 0; n < bufferSize; n++) this.channelOutputBuffer.array[n] = 0;
        }

        // Apply roll
        this.roll.process(this.channelOutputBuffer.pointer, this.channelOutputBuffer.pointer, bufferSize);

        // Apply filters
        this.lowpassFilter.process(this.channelOutputBuffer.pointer, this.channelOutputBuffer.pointer, bufferSize);
        this.hipassFilter.process(this.channelOutputBuffer.pointer, this.channelOutputBuffer.pointer, bufferSize);

        // Apply final stage gain
        this.Superpowered.Volume(
            this.channelOutputBuffer.pointer,
            this.channelOutputBuffer.pointer,
            this.volume,
            this.volume,
            bufferSize
        );
    }

    destroy() {
        this.player.destroy();
        this.roll.destroy();
        this.lowpassFilter.destroy();
        this.hipassFilter.destroy();
    }
}

export default MixerChannel