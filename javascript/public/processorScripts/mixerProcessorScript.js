// Import the SuperpoweredWebAudio helper to allow us to extend the SuperpoweredWebAudio.AudioWorkletProcessor class
import "https://creativelycommon-public-assets.s3.eu-west-2.amazonaws.com/superpowered/2.6.2/superpowered.wasm";

import MixerEngine from './mixerEngine.js';

class MixerProcessor extends SuperpoweredWebAudio.AudioWorkletProcessor {


  onReady() {
    this.started = false;
    this.assetsLoaded = 0;
    this.mixerEngine = new MixerEngine(this.Superpowered, this.samplerate, 2);

    this.channelA = this.mixerEngine.channels[0];
    this.channelB = this.mixerEngine.channels[1];

    // Pass an event object over to the main scope to tell it everything is ready
    this.sendMessageToMainScope({ event: "ready" });

    this.loadAssetFromProcessor = this.loadAssetFromProcessor.bind(this);
  }

  loadAssetFromProcessor(url) {
    this.Superpowered.downloadAndDecode(
      url,
      this
    );
  }

  // onDestruct is called when the parent AudioWorkletNode.destruct() method is called.
  // You should clear up all SP class instances here.
  onDestruct() {
    this.mixerEngine.destroy();
  }

  onMessageFromMainScope(message) {
    if (message.type === "parameterChange") {
      this.handleIncomingParameterChange(message.data.scope, message.data.paramName, message.data.channelIndex, message.data.value);
    }
    if (message.type === "command") {
      this.handleIncomingCommand(message);
    }
    if (message.SuperpoweredLoaded) {
      this.handleAssetLoaded(message);
      if (this.assetsLoaded === 2) {
        this.sendMessageToMainScope({ event: "assetsLoaded" });
      }
    }
  }

  handleAssetLoaded(message) {
    const foundAsset = this.mixerAssets.find(a => a.url === message.SuperpoweredLoaded.url);
    const destinationChannelIndex = this.mixerAssets.indexOf(foundAsset);
    this.mixerEngine.channels[destinationChannelIndex].loadBuffer(message.SuperpoweredLoaded.buffer, foundAsset);
    this.assetsLoaded++;
  }

  handleIncomingCommand(message) {
      if (message.payload?.id === "loadPlayerAssets") {
        this.mixerAssets = message.payload.assets;
        this.mixerAssets.forEach((asset) => {
          this.loadAssetFromProcessor(asset.url);
        });
        
      }
      if (message.payload?.id === "startPlayback") {
        this.channelA.configure(126, 353);
        this.channelB.configure(123, 40);
        this.channelA.setSyncToBPM(this.channelA.getCurrentBPM());
        this.channelB.setSyncToBPM(this.channelA.getCurrentBPM());

        this.mixerEngine.togglePlay();
      }
      if (message.payload?.id === "stopPlayback") {
        this.mixerEngine.togglePlay();
      }
      
      if (message.payload?.id === 'setTempo') {
        this.mixerEngine.setTempo(message.payload.tempo)
      }
      if (message.payload?.id === 'requestPeaks') {
        this.sendMessageToMainScope({
          type: "peakData",
          peaks: {
            master: this.mixerEngine.outputPeak,
            a: this.mixerEngine.channelAPeak,
            b: this.mixerEngine.channelBPeak,
          }
        })
      }
  }

  handleIncomingParameterChange(scope, paramName, channelIndex, value) {
    if (scope === 'global') this.applyGlobalParamChange(paramName, channelIndex, value);
    if (scope === 'channel') this.applyChannelParamChange(paramName, channelIndex, value);
  }

  applyChannelParamChange(paramName, channelIndex, value) {
      switch (paramName) {
          case 'channelGain':
              this.mixerEngine.channels[channelIndex].setVolume(value);
              break;
          case 'filterFrequency':
              this.mixerEngine.channels[channelIndex].setFilterFrequencyPosition(value);
              break;
          case 'roll':
              if (value) {
                  this.mixerEngine.channels[channelIndex].setRollEnabled(value);
              } else {
                  this.mixerEngine.channels[channelIndex].setRollDisabled();
              }
              break;
          case 'pitch':
              this.mixerEngine.channels[channelIndex].setPitchShift(value);
              break;
          default:
              break;
      }
  }

  applyGlobalParamChange(paramName, channelIndex, value) {
      switch (paramName) {
          case 'crossFaderPosition':
              this.mixerEngine.setCrossFaderPosition(value);
              break;
          default:
              break;
      }
  }

  processAudio(inputBuffer, outputBuffer, buffersize, parameters) {
    // Call the process block on the mixer engine;
    this.mixerEngine.process(inputBuffer, outputBuffer, buffersize, this.samplerate);
  }
}

// The following code registers the processor script in the browser, notice the label and reference
if (typeof AudioWorkletProcessor !== "undefined")
  registerProcessor("MixerProcessor", MixerProcessor);
export default MixerProcessor;
