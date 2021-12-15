//
//  AudioEngine.h
//  SuperpoweredUniversalApp (iOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioEngine : NSObject

- (void)togglePlay;
- (void)setCrossFaderPosition:(float)newValue;
- (void)setTempo:(float)newValue;
- (float)peak;

- (void)setVolume:(float)newVolume channel:(int)channel;
- (float)peakForChannel:(int)channel;
- (int)pitchShiftForChannel:(int)channel;
- (void)setPitchShift:(int)newValue channel:(int)channel;
- (void)setFilterFrequencyPosition:(float)newValue channel:(int)channel;
- (void)setRollEnabled:(float)beats channel:(int)channel;
- (void)setRollDisabledForChannel:(int)channel;

- (BOOL)processBuffer:(float *)buffer numberOfFrames:(unsigned int)numberOfFrames sampleRate:(unsigned int)sampleRate;

@end

NS_ASSUME_NONNULL_END
