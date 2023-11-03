// Here we create a centralised audio engine, outside of React's lifecycles.
import { SuperpoweredGlue, SuperpoweredWebAudio } from 'superpowered-sdk';

class AudioEngine {
    initted = false;
    requested = false;

    async loadSuperpoweredLibrary(licenseKey, wasmUrl)  {
        const minimumSampleRate = 48000; // firefox has a bug...
        
        if (!this.initted && !this.requested) {
            this.requested = true;
            
            this.superpowered = await SuperpoweredGlue.Instantiate(
                licenseKey
            );
            console.log(`Superpowered version: ${this.superpowered.Version()}`);

            // We now use the SuperpoweredWebAudio helper to create an AudioContext
            this.webaudioManager = new SuperpoweredWebAudio(minimumSampleRate, this.superpowered, true);
            this.initted = true;

            // Although this will usually happen by default, we suspend the audio context until user interaction with the page.
            this.suspend();
        } 
    }

    suspend() {
        this.webaudioManager.audioContext.suspend();
    }

    resume() {
        this.webaudioManager.audioContext.resume();
    }

}

const audioEngine = new AudioEngine();
export default audioEngine;