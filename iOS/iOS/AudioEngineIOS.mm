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
    float *buffer;
}

- (instancetype)init {
    if (self = [super init]) {

        buffer = (float*) malloc(sizeof(float) * 48000 * 2);

        _audioIO = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];

        [_audioIO start];
    }
    return self;
}

- (void)dealloc {
    free(buffer);
}

static bool audioProcessing(void *clientdata, float **inputBuffers, unsigned int inputChannels, float **outputBuffers, unsigned int outputChannels, unsigned int numberOfFrames, unsigned int samplerate, uint64_t hostTime) {
    __unsafe_unretained AudioEngineIOS *self = (__bridge AudioEngineIOS *)clientdata;
    bool result = [self audioProcessing:outputBuffers[0] right:outputBuffers[1] numFrames:numberOfFrames samplerate:samplerate];
    return result;
}

- (bool)audioProcessing:(float *)leftOutput right:(float *)rightOutput numFrames:(unsigned int)numberOfFrames samplerate:(unsigned int)samplerate {
    memset(buffer, 0, sizeof(float) * numberOfFrames * 2);
    Superpowered::Interleave(leftOutput, rightOutput, buffer, numberOfFrames);
    BOOL hasOutput = [self processBuffer:buffer numberOfFrames:numberOfFrames sampleRate:samplerate];
    if (!hasOutput) {
        memset(buffer, 0, sizeof(float) * numberOfFrames * 2);
    }
    Superpowered::DeInterleave(buffer, leftOutput, rightOutput, numberOfFrames);
    return true;
}


@end
