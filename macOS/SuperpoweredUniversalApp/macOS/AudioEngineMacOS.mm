//
//  AudioEngineMacOS.m
//  SuperpoweredUniversalApp (macOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#import "AudioEngineMacOS.h"
#import "SuperpoweredOSXAudioIO.h"
#import "SuperpoweredSimple.h"

@interface AudioEngineMacOS ()
@property (nonatomic, strong) SuperpoweredOSXAudioIO *audioIO;
@end

@implementation AudioEngineMacOS {
}

- (instancetype)init {
    if (self = [super init]) {
        _audioIO = [[SuperpoweredOSXAudioIO alloc] initWithDelegate:(id<SuperpoweredOSXAudioIODelegate>)self preferredBufferSizeMs:12 numberOfChannels:2 enableInput:false enableOutput:true];

        [_audioIO start];
    }
    return self;
}

- (void)dealloc {
}


- (bool)audioProcessingCallback:(float *)inputBuffer outputBuffer:(float *)outputBuffer numberOfFrames:(unsigned int)numberOfFrames samplerate:(unsigned int)samplerate hostTime:(UInt64)hostTime {
    BOOL hasOutput = [self processBuffer:outputBuffer numberOfFrames:numberOfFrames sampleRate:samplerate];
    return hasOutput;
}


@end
