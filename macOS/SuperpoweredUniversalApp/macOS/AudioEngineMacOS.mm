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
    float *buffer;
}

- (instancetype)init {
    if (self = [super init]) {

        const unsigned int maximumSampleRate = 192000;
        buffer = (float*) malloc(sizeof(float) * maximumSampleRate * 2);

        _audioIO = [[SuperpoweredOSXAudioIO alloc] initWithDelegate:(id<SuperpoweredOSXAudioIODelegate>)self preferredBufferSizeMs:12 numberOfChannels:2 enableInput:false enableOutput:true];

        [_audioIO start];
    }
    return self;
}

- (void)dealloc {
    free(buffer);
}

- (bool)audioProcessingCallback:(float **)inputBuffers inputChannels:(unsigned int)inputChannels outputBuffers:(float **)outputBuffers outputChannels:(unsigned int)outputChannels numberOfFrames:(unsigned int)numberOfFrames samplerate:(unsigned int)samplerate hostTime:(unsigned long long int)hostTime {
    memset(buffer, 0, sizeof(float) * numberOfFrames * 2);
    Superpowered::Interleave(outputBuffers[0], outputBuffers[1], buffer, numberOfFrames);
    BOOL hasOutput = [self processBuffer:buffer numberOfFrames:numberOfFrames sampleRate:samplerate];
    if (!hasOutput) {
        memset(buffer, 0, sizeof(float) * numberOfFrames * 2);
    }
    Superpowered::DeInterleave(buffer, outputBuffers[0], outputBuffers[1], numberOfFrames);

    return true;
}


@end
