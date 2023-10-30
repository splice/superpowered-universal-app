//
//  AudioEngineIOS.m
//  SuperpoweredUniversalApp (iOS)
//
//  Created by Balázs Kiss on 2021. 11. 23..
//

#import "AudioEngineIOS.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredSimple.h"

@interface AudioEngineIOS ()
@property (nonatomic, strong) SuperpoweredIOSAudioIO *audioIO;
@end

@implementation AudioEngineIOS {
}

- (instancetype)init {
    if (self = [super init]) {
        _audioIO = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];

        [_audioIO start];
    }
    return self;
}

- (void)dealloc {
}

static bool audioProcessing(void *clientdata, float *input, float *output, unsigned int numberOfFrames, unsigned int samplerate, uint64_t hostTime) {
    __unsafe_unretained AudioEngineIOS *self = (__bridge AudioEngineIOS *)clientdata;
    bool result = [self audioProcessing:output numFrames:numberOfFrames samplerate:samplerate];
    return result;
}


- (bool)audioProcessing:(float *)output numFrames:(unsigned int)numberOfFrames samplerate:(unsigned int)samplerate {
    BOOL hasOutput = [self processBuffer:output numberOfFrames:numberOfFrames sampleRate:samplerate];
    return hasOutput;
}


@end
