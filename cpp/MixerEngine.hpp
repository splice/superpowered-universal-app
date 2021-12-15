//
//  MixerEngine.hpp
//  SuperpoweredUniversalApp
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#ifndef MixerEngine_hpp
#define MixerEngine_hpp

#include <atomic>
#include <stdio.h>
#include "MixerChannel.hpp"
#include "SuperpoweredMixer.h"



class MixerEngine {
public:
    MixerEngine(MixerChannelAsset assetA, MixerChannelAsset assetB);
    ~MixerEngine();

    void togglePlay();
    float getPeak();
    void setCrossFaderPosition(float newValue);
    void setTempo(float newValue);
    bool process(float *buffer, unsigned int numberOfFrames, unsigned int sampleRate);

    void setChannelVolume(int channel, float newVolume);
    float getChannelPeak(int channel);
    int getChannelPitchShift(int channel);
    void setChannelPitchShift(int channel, int newValue);
    void setChannelFilterFrequencyPosition(int channel, float newValue);
    void setChannelRollEnabled(int channel, float beats);
    void setChannelRollDisable(int channel);

private:
    MixerChannel *channel0;
    MixerChannel *channel1;
    StereoMixer *channelMixer;
    float *channel0Buffer;
    float *channel1Buffer;
    std::atomic<float> peak;
    std::atomic<float> crossFaderPosition;
    bool isLoaded;

    float limit(float value, float min, float max);
    MixerChannel *channelWithIndex(int index);
};

#endif /* MixerEngine_hpp */
