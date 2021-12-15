//
//  AudioEngine.m
//  SuperpoweredUniversalApp (iOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#import "AudioEngine.h"
#import "MixerEngine.hpp"
#import "Superpowered.h"
#import "SuperpoweredSimple.h"

@implementation AudioEngine {
    MixerEngine *mixer;
}

- (instancetype)init {
    if (self = [super init]) {
        Initialize("ExampleLicenseKey-WillExpire-OnNextUpdate", false, false, true, true, true, false, false);

        MixerChannelAsset assetA = MixerChannelAsset();
        assetA.filePath = [[[NSBundle mainBundle] pathForResource:@"lycka" ofType:@"mp3"] fileSystemRepresentation];
        assetA.originalBPM = 126;
        assetA.firstBeatMs = 353;

        MixerChannelAsset assetB = MixerChannelAsset();
        assetB.filePath = [[[NSBundle mainBundle] pathForResource:@"nuyorica" ofType:@"m4a"] fileSystemRepresentation];
        assetB.originalBPM = 123;
        assetB.firstBeatMs = 40;

        mixer = new MixerEngine(assetA, assetB);
    }
    return self;
}

- (void)dealloc {
    delete mixer;
}

- (BOOL)processBuffer:(float *)buffer numberOfFrames:(unsigned int)numberOfFrames sampleRate:(unsigned int)sampleRate {
    bool hasOutput = mixer->process(buffer, numberOfFrames, sampleRate);
    return hasOutput;
}

- (void)togglePlay {
    mixer->togglePlay();
}

- (void)setVolume:(float)newVolume channel:(int)channel {
    mixer->setChannelVolume(channel, newVolume);
}

- (float)peakForChannel:(int)channel {
    return mixer->getChannelPeak(channel);
}

- (float)peak {
    return mixer->getPeak();
}

- (int)pitchShiftForChannel:(int)channel {
    return mixer->getChannelPitchShift(channel);
}

- (void)setPitchShift:(int)newValue channel:(int)channel {
    mixer->setChannelPitchShift(channel, newValue);
}

- (void)setCrossFaderPosition:(float)newValue {
    mixer->setCrossFaderPosition(newValue);
}

- (void)setFilterFrequencyPosition:(float)newValue channel:(int)channel {
    mixer->setChannelFilterFrequencyPosition(channel, newValue);
}

- (void)setRollEnabled:(float)beats channel:(int)channel {
    mixer->setChannelRollEnabled(channel, beats);
}

- (void)setRollDisabledForChannel:(int)channel {
    mixer->setChannelRollDisable(channel);
}

- (void)setTempo:(float)newValue {
    mixer->setTempo(newValue);
}

@end
