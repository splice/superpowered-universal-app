//
//  MixerEngine.cpp
//  SuperpoweredUniversalApp
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#include "MixerEngine.hpp"
#include <stdlib.h>
#include <cstring>
#include <cmath>
#include "SuperpoweredSimple.h"

#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.05);
static const unsigned int maximumSampleRate = 192000;

MixerEngine::MixerEngine(MixerChannelAsset assetA, MixerChannelAsset assetB) {
    channel0 = new MixerChannel(assetA);
    channel1 = new MixerChannel(assetB);
    channelMixer = new StereoMixer();

    channel0Buffer = (float *)malloc(sizeof(float) * maximumSampleRate * 2);
    channel1Buffer = (float *)malloc(sizeof(float) * maximumSampleRate * 2);

    peak.store(0);
    setCrossFaderPosition(0.5);
    isLoaded = false;
}

MixerEngine::~MixerEngine() {
    delete channel0;
    delete channel1;
    delete channelMixer;
    free(channel0Buffer);
    free(channel1Buffer);
}

float MixerEngine::limit(float value, float min, float max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

MixerChannel *MixerEngine::channelWithIndex(int index) {
    if (index == 0) {
        return channel0;
    } else if (index == 1) {
        return channel1;
    } else {
        return NULL;
    }
}

void MixerEngine::togglePlay() {
    channel0->togglePlay(true);
    channel1->togglePlay(false);
}

float MixerEngine::getPeak() {
    return limit(peak.load(), 0, 1);
}

void MixerEngine::setCrossFaderPosition(float newValue) {
    crossFaderPosition.store(newValue);
    const float gainChannel0 = cosf(M_PI_2 * newValue) * headroom;
    const float gainChannel1 = cosf(M_PI_2 * (1.0f - newValue)) * headroom;
    channelMixer->inputGain[0] = gainChannel0;
    channelMixer->inputGain[1] = gainChannel0;
    channelMixer->inputGain[2] = gainChannel1;
    channelMixer->inputGain[3] = gainChannel1;
}

void MixerEngine::setChannelVolume(int channel, float newVolume) {
    channelWithIndex(channel)->setVolume(newVolume);
}

float MixerEngine::getChannelPeak(int channel) {
    return limit(channelWithIndex(channel)->getPeak(), 0, 1);
}

int MixerEngine::getChannelPitchShift(int channel) {
    return channelWithIndex(channel)->getPitchShift();
}

void MixerEngine::setChannelPitchShift(int channel, int newValue) {
    channelWithIndex(channel)->setPitchShift(newValue);
}

bool MixerEngine::process(float *buffer, unsigned int numberOfFrames, unsigned int sampleRate) {
    if (!isLoaded && channel0->getIsLoaded() && channel1->getIsLoaded()) {
        channel0->prepareToPlay();
        channel1->prepareToPlay();
        channel0->setSyncToBPM(channel0->getCurrentBPM());
        channel1->setSyncToBPM(channel0->getCurrentBPM());
        isLoaded = true;
    }

    memset(channel0Buffer, 0, numberOfFrames * sizeof(float) * 2);
    memset(channel1Buffer, 0, numberOfFrames * sizeof(float) * 2);

    bool silence1 = !channel0->process(channel0Buffer, numberOfFrames, sampleRate);
    bool silence2 = !channel1->process(channel1Buffer, numberOfFrames, sampleRate);
    bool silence = silence1 && silence2;

    channelMixer->process(channel0Buffer, channel1Buffer, NULL, NULL, buffer, numberOfFrames);

    const float bufferPeak = Superpowered::Peak(buffer, numberOfFrames * 2);
    peak.store(bufferPeak);
    return !silence;
}

void MixerEngine::setChannelFilterFrequencyPosition(int channel, float newValue) {
    channelWithIndex(channel)->setFilterFrequencyPosition(newValue);
}

void MixerEngine::setChannelRollEnabled(int channel, float beats) {
    channelWithIndex(channel)->setRollEnabled(beats);
}

void MixerEngine::setChannelRollDisable(int channel) {
    channelWithIndex(channel)->setRollDisabled();
}

void MixerEngine::setTempo(float newValue) {
    channel0->setSyncToBPM(newValue);
    channel1->setSyncToBPM(newValue);
}
