//
//  MixerChannel.hpp
//  SuperpoweredUniversalApp (iOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#ifndef MixerChannel_hpp
#define MixerChannel_hpp

#include <atomic>
#include <stdio.h>
#include "SuperpoweredAdvancedAudioPlayer.h"
#include "SuperpoweredFilter.h"
#include "SuperpoweredRoll.h"

using namespace Superpowered;

struct MixerChannelAsset {
    const char *filePath = nullptr;
    int fileOffset = 0;
    int fileLength = 0;
    double originalBPM = 0;
    double firstBeatMs = 0;
};

class MixerChannel {
public:
    MixerChannel(MixerChannelAsset asset);
    ~MixerChannel();

    void togglePlay(bool isMaster);
    bool process(float *buffer, unsigned int numberOfFrames, unsigned int sampleRate);
    void setVolume(float newVolume);
    float getPeak();
    int getPitchShift();
    void setPitchShift(int newValue);
    bool getIsLoaded();
    void prepareToPlay();
    double getCurrentBPM();
    void setSyncToBPM(double bpm);
    void setFilterFrequencyPosition(float newValue);
    void setRollEnabled(float beats);
    void setRollDisabled();

private:
    MixerChannelAsset asset;
    unsigned int sampleRate;
    AdvancedAudioPlayer *player;
    std::atomic<float> volume;
    std::atomic<float> peak;
    bool isLoaded;
    Filter *lowPassFilter;
    Filter *highPassFilter;
    Roll *roll;

    void setSampleRate(unsigned int newSampleRate);
};

#endif /* MixerChannel_hpp */
