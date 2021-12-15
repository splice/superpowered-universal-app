//
//  MixerChannel.cpp
//  SuperpoweredUniversalApp (iOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#include "MixerChannel.hpp"
#include "SuperpoweredSimple.h"

MixerChannel::MixerChannel(MixerChannelAsset asset) {
    this->asset = asset;
    const unsigned int initialSampleRate = 44100;
    sampleRate = initialSampleRate;

    volume.store(0.8);
    peak.store(0);
    isLoaded = false;

    player = new AdvancedAudioPlayer(sampleRate, 0);
    if (asset.fileLength != 0) {
        player->open(asset.filePath, asset.fileOffset, asset.fileLength);
    } else {
        player->open(asset.filePath);
    }

    roll = new Roll(sampleRate);
    roll->wet = 1;
    roll->enabled = false;

    lowPassFilter = new Filter(Filter::FilterType::Resonant_Lowpass, sampleRate);
    lowPassFilter->octave = 2;
    lowPassFilter->resonance = 0.05;
    lowPassFilter->enabled = false;

    highPassFilter = new Filter(Filter::FilterType::Resonant_Highpass, sampleRate);
    highPassFilter->octave = 2;
    highPassFilter->resonance = 0.05;
    highPassFilter->enabled = false;
}

MixerChannel::~MixerChannel() {
    delete player;
    delete lowPassFilter;
    delete highPassFilter;
    delete roll;
}

bool MixerChannel::getIsLoaded() {
    return isLoaded;
}

void MixerChannel::togglePlay(bool isMaster) {
    if (player->isPlaying()) {
        player->pause();
    } else {
        if (isMaster) {
            player->play();
        } else {
            player->playSynchronized();
        }
    }
}

void MixerChannel::setVolume(float newVolume) {
    volume.store(newVolume);
}

float MixerChannel::getPeak() {
    return peak.load();
}

int MixerChannel::getPitchShift() {
    return player->pitchShiftCents / 100;
}

void MixerChannel::setPitchShift(int newValue) {
    player->pitchShiftCents = newValue * 100;
}

void MixerChannel::setSampleRate(unsigned int newSampleRate) {
    this->sampleRate = newSampleRate;
    player->outputSamplerate = newSampleRate;
    roll->samplerate = newSampleRate;
    lowPassFilter->samplerate = newSampleRate;
    highPassFilter->samplerate = newSampleRate;
}

bool MixerChannel::process(float *buffer, unsigned int numberOfFrames, unsigned int sampleRate) {
    if (this->sampleRate != sampleRate) {
        setSampleRate(sampleRate);
    }
    if (player->getLatestEvent() == Superpowered::AdvancedAudioPlayer::PlayerEvent_Opened) {
        isLoaded = true;
    }
    bool hasOutput = player->processStereo(buffer, false, numberOfFrames, 1.0f);

    if (player->syncToBpm != 0) {
        roll->bpm = player->syncToBpm;
    }
    roll->process(buffer, buffer, numberOfFrames);

    lowPassFilter->process(buffer, buffer, numberOfFrames);
    highPassFilter->process(buffer, buffer, numberOfFrames);

    Superpowered::Volume(buffer, buffer, volume.load(), volume.load(), numberOfFrames);
    peak.store(Superpowered::Peak(buffer, numberOfFrames * 2));
    return hasOutput;
}

void MixerChannel::prepareToPlay() {
    player->originalBPM = asset.originalBPM;
    player->firstBeatMs = asset.firstBeatMs;
    player->syncMode = Superpowered::AdvancedAudioPlayer::SyncMode_TempoAndBeat;
    player->setPosition(player->firstBeatMs, false, false);
}

double MixerChannel::getCurrentBPM() {
    return player->getCurrentBpm();
}

void MixerChannel::setSyncToBPM(double bpm) {
    player->syncToBpm = bpm;
}

void MixerChannel::setFilterFrequencyPosition(float newValue) {
    const float maxFrequency = 3000;
    const float minFrequency = 200;

    const float newValueHz = (newValue - 0.5) * (maxFrequency / 0.5);

    if (newValueHz < 0 - minFrequency) {
        highPassFilter->enabled = false;
        lowPassFilter->enabled = true;
        lowPassFilter->frequency = newValueHz + maxFrequency + minFrequency;
    } else if (newValueHz > minFrequency) {
        lowPassFilter->enabled = false;
        highPassFilter->enabled = true;
        highPassFilter->frequency = newValueHz;
    } else {
        lowPassFilter->enabled = false;
        highPassFilter->enabled = false;
    }
}

void MixerChannel::setRollEnabled(float beats) {
    roll->beats = beats;
    roll->enabled = true;
}

void MixerChannel::setRollDisabled() {
    roll->enabled = false;
}
