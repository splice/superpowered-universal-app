// Here we create a centralised audio engine, outside of React's lifecycles.

class AudioEngine {
    initted = false;
    requested = false;

    async loadSuperpoweredLibrary(licenseKey, libraryUrl)  {
        const minimumSampleRate = 48000; // firefox has a bug...
        
        if (!this.initted && !this.requested) {
            this.requested = true;
            // Here we tell Superpowered to pull a publically available copy of the lib in at runtime to avoid bundler/transpiler issues
            await import(/* webpackIgnore: true */ libraryUrl);

            // With the Superpowered library imported, we now instantiate it.
            // eslint-disable-next-line no-undef
            this.superpowered = await SuperpoweredGlue.Instantiate(
                licenseKey, 
                libraryUrl
            );
            // We now use the SuperpoweredWebAudio helper to create an AudioContext
            // eslint-disable-next-line no-undef
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