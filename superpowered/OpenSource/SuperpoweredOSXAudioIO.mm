#import "SuperpoweredOSXAudioIO.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#define MAXFRAMES 4096

@implementation SuperpoweredOSXAudioIO {
    id<SuperpoweredOSXAudioIODelegate>delegate;
    audioProcessingCallback_C processingCallback;
    void *processingClientdata;
    
    AudioUnit inputUnit, outputUnit;
    AudioBufferList *inputBuffers0, *inputBuffers1;
    float **inputBufs0, **inputBufs1;

    NSString *mapOutputDeviceName, *mapInputDeviceName;
    int numberOfChannels, samplerate, inputFrames, inputChannels, mapNumInputChannels, mapNumOutputChannels;
    bool shouldRun, hasInput, inputEven, outputEven;
}

@synthesize preferredBufferSizeMs, inputEnabled, outputEnabled;

static OSStatus audioInputCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    SuperpoweredOSXAudioIO *self = (__bridge SuperpoweredOSXAudioIO *)inRefCon;

    div_t d = div(inNumberFrames, 8);
    if ((d.rem != 0) || (inNumberFrames < 32) || (inNumberFrames > MAXFRAMES)) {
        return kAudioUnitErr_InvalidParameter;
    };

    self->inputFrames = inNumberFrames;
    self->hasInput = !AudioUnitRender(self->inputUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, self->inputEven ? self->inputBuffers0 : self->inputBuffers1);
    
    if (self->hasInput && !self->outputEnabled) {
        float **inputBufs = self->inputEven ? self->inputBufs0 : self->inputBufs1;
        if (self->processingCallback) self->processingCallback(self->processingClientdata, inputBufs, self->inputChannels, NULL, self->numberOfChannels, inNumberFrames, self->samplerate, inTimeStamp->mHostTime);
        else if (self->delegate) [self->delegate audioProcessingCallback:inputBufs inputChannels:self->inputChannels outputBuffers:NULL outputChannels:self->numberOfChannels numberOfFrames:inNumberFrames samplerate:self->samplerate hostTime:inTimeStamp->mHostTime];
    }
    
    self->inputEven = !self->inputEven;
	return noErr;
}

static OSStatus audioOutputCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    SuperpoweredOSXAudioIO *self = (__bridge SuperpoweredOSXAudioIO *)inRefCon;

    div_t d = div(inNumberFrames, 8);
    if ((d.rem != 0) || (inNumberFrames < 32) || (inNumberFrames > MAXFRAMES) || (ioData->mNumberBuffers != self->numberOfChannels)) {
        return kAudioUnitErr_InvalidParameter;
    };

    float *outputBufs[self->numberOfChannels], **inputBufs = self->outputEven ? self->inputBufs0 : self->inputBufs1;
    for (int n = 0; n < self->numberOfChannels; n++) outputBufs[n] = (float *)ioData->mBuffers[n].mData;
    bool silence = true;
    int inputChannels = self->hasInput && self->inputEnabled && (self->inputFrames == inNumberFrames) ? self->inputChannels : 0;
    self->outputEven = !self->outputEven;

    if (self->processingCallback) silence = !self->processingCallback(self->processingClientdata, inputBufs, inputChannels, outputBufs, self->numberOfChannels, inNumberFrames, self->samplerate, inTimeStamp->mHostTime);
    else if (self->delegate) silence = ![self->delegate audioProcessingCallback:inputBufs inputChannels:inputChannels outputBuffers:outputBufs outputChannels:self->numberOfChannels numberOfFrames:inNumberFrames samplerate:self->samplerate hostTime:inTimeStamp->mHostTime];

    if (silence) {
        // Output silence.
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        // Despite of ioActionFlags, it outputs garbage sometimes, so must zero the buffers:
        for (unsigned char n = 0; n < ioData->mNumberBuffers; n++) memset(ioData->mBuffers[n].mData, 0, ioData->mBuffers[n].mDataByteSize);
    };
    
    return noErr;
}

static OSStatus defaultDeviceChangedCallback(AudioObjectID inObjectID, UInt32 inNumberAddresses, const AudioObjectPropertyAddress inAddresses[], void *inClientData) {
    SuperpoweredOSXAudioIO *self = (__bridge SuperpoweredOSXAudioIO *)inClientData;
    dispatch_async(dispatch_get_main_queue(), ^{ [self recreate]; });
    return noErr;
}

static OSStatus devicesChangedCallback(AudioObjectID inObjectID, UInt32 inNumberAddresses, const AudioObjectPropertyAddress inAddresses[], void *inClientData) {
    SuperpoweredOSXAudioIO *self = (__bridge SuperpoweredOSXAudioIO *)inClientData;
    dispatch_async(dispatch_get_main_queue(), ^{
        audioDevice *devices = [SuperpoweredOSXAudioIO getAudioDevices], *next;
        if ([self->delegate respondsToSelector:@selector(audioDevicesChanged:)]) [self->delegate audioDevicesChanged:devices];
        while (devices) {
            next = devices->next;
            if (devices->name) free(devices->name);
            free(devices);
            devices = next;
        }
    });
    return noErr;
}

- (id)initWithDelegate:(id<SuperpoweredOSXAudioIODelegate>)del preferredBufferSizeMs:(unsigned int)bufferSizeMs numberOfChannels:(int)channels enableInput:(bool)enableInput enableOutput:(bool)enableOutput {
    return [self initWithDelegate:del preferredBufferSizeMs:bufferSizeMs numberOfChannels:channels enableInput:enableInput enableOutput:enableOutput audioDeviceID:UINT_MAX];
}

- (id)initWithDelegate:(id<SuperpoweredOSXAudioIODelegate>)del preferredBufferSizeMs:(unsigned int)bufferSizeMs numberOfChannels:(int)channels enableInput:(bool)enableInput enableOutput:(bool)enableOutput audioDeviceID:(unsigned int)deviceID {
    self = [super init];
    if (self) {
        if (bufferSizeMs < 1) bufferSizeMs = 10;
        numberOfChannels = channels;
        self->preferredBufferSizeMs = bufferSizeMs;
        self->inputEnabled = enableInput;
        self->outputEnabled = enableOutput;
        audioDeviceID = deviceID;
        samplerate = 0;
        shouldRun = false;
        inputUnit = outputUnit = NULL;
        delegate = del;
        processingCallback = NULL;
        processingClientdata = NULL;
        inputFrames = inputChannels = 0;
        hasInput = false;
        inputEven = outputEven = true;

        inputBuffers0 = (AudioBufferList *)malloc(offsetof(AudioBufferList, mBuffers[0]) + (sizeof(AudioBuffer) * numberOfChannels));
        inputBuffers1 = (AudioBufferList *)malloc(offsetof(AudioBufferList, mBuffers[0]) + (sizeof(AudioBuffer) * numberOfChannels));
        inputBufs0 = (float **)malloc(sizeof(float *) * numberOfChannels);
        inputBufs1 = (float **)malloc(sizeof(float *) * numberOfChannels);
        if (!inputBuffers0 || !inputBuffers1 || !inputBufs0 || !inputBufs1) abort();
        for (int n = 0; n < numberOfChannels; n++) {
            inputBuffers0->mBuffers[n].mData = calloc(1, MAXFRAMES * 4);
            inputBuffers1->mBuffers[n].mData = calloc(1, MAXFRAMES * 4);
            if (!inputBuffers0->mBuffers[n].mData || !inputBuffers1->mBuffers[n].mData) abort();
            inputBufs0[n] = (float *)inputBuffers0->mBuffers[n].mData;
            inputBufs1[n] = (float *)inputBuffers1->mBuffers[n].mData;
            inputBuffers0->mBuffers[n].mDataByteSize = inputBuffers1->mBuffers[n].mDataByteSize = MAXFRAMES * 4;
            inputBuffers0->mBuffers[n].mNumberChannels = inputBuffers1->mBuffers[n].mNumberChannels = 1;
        };
        inputBuffers0->mNumberBuffers = inputBuffers1->mNumberBuffers = numberOfChannels;

        CFRunLoopRef runLoop = NULL;
        AudioObjectPropertyAddress rladdress = { kAudioHardwarePropertyRunLoop, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
        AudioObjectSetPropertyData(kAudioObjectSystemObject, &rladdress, 0, NULL, sizeof(CFRunLoopRef), &runLoop);
        AudioObjectPropertyAddress ddaddress = { enableInput && !enableOutput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
        AudioObjectAddPropertyListener(kAudioObjectSystemObject, &ddaddress, defaultDeviceChangedCallback, (__bridge void *)self);
        AudioObjectPropertyAddress hdaddress = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
        AudioObjectAddPropertyListener(kAudioObjectSystemObject, &hdaddress, devicesChangedCallback, (__bridge void *)self);

        [self createAudioUnits];
    };
    return self;
}

- (void)setProcessingCallback_C:(audioProcessingCallback_C)callback clientdata:(void *)clientdata {
    processingCallback = callback;
    processingClientdata = clientdata;
}

static void destroyUnit(AudioComponentInstance *unit) {
    if (*unit == NULL) return;
    AudioOutputUnitStop(*unit);
    AudioUnitUninitialize(*unit);
    AudioComponentInstanceDispose(*unit);
    *unit = NULL;
}

- (void)dealloc {
    AudioObjectPropertyAddress ddaddress = { kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &ddaddress, defaultDeviceChangedCallback, (__bridge void *)self);
    ddaddress.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &ddaddress, defaultDeviceChangedCallback, (__bridge void *)self);
    AudioObjectPropertyAddress hdaddress = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &hdaddress, devicesChangedCallback, (__bridge void *)self);
    
    destroyUnit(&inputUnit);
    destroyUnit(&outputUnit);
    for (int n = 0; n < numberOfChannels; n++) {
        free(inputBuffers0->mBuffers[n].mData);
        free(inputBuffers1->mBuffers[n].mData);
    };
    free(inputBuffers0);
    free(inputBuffers1);
    free(inputBufs0);
    free(inputBufs1);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)recreate {
    [self performSelector:@selector(createAudioUnits) withObject:nil afterDelay:1.0];
}

static void streamFormatChangedCallback(void *inRefCon, AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement) {
    SuperpoweredOSXAudioIO *self = (__bridge SuperpoweredOSXAudioIO *)inRefCon;
    if (
        ((inUnit == self->outputUnit) && (inScope == kAudioUnitScope_Output) && (inElement == 0)) ||
        ((inUnit == self->inputUnit) && (inScope == kAudioUnitScope_Input) && (inElement == 1))
        )
        dispatch_async(dispatch_get_main_queue(), ^{ [self recreate]; });
}

static AudioDeviceID getDefaultAudioDevice(bool input) {
    AudioDeviceID deviceID = 0;
    UInt32 size = sizeof(AudioDeviceID);
    AudioObjectPropertyAddress address = { input ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    return (AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &deviceID) == noErr) ? deviceID : UINT_MAX;
}

static bool enableOutput(AudioUnit au, bool enable) {
    UInt32 value = enable ? 1 : 0;
    return !AudioUnitSetProperty(au, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &value, sizeof(value));
}

static bool enableInput(AudioUnit au, bool enable) {
    UInt32 value = enable ? 1 : 0;
    return !AudioUnitSetProperty(au, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &value, sizeof(value));
}

static void makeStreamFormat(AudioUnit au, AudioStreamBasicDescription *format, bool input) {
    UInt32 size = 0;
    AudioUnitGetPropertyInfo(au, kAudioUnitProperty_StreamFormat, input ? kAudioUnitScope_Input : kAudioUnitScope_Output, input ? 1 : 0, &size, NULL);
    AudioUnitGetProperty(au, kAudioUnitProperty_StreamFormat, input ? kAudioUnitScope_Input : kAudioUnitScope_Output, input ? 1 : 0, format, &size);
    format->mFormatID = kAudioFormatLinearPCM;
    format->mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagsNativeEndian;
    format->mBitsPerChannel = 32;
    format->mFramesPerPacket = 1;
    format->mBytesPerFrame = 4;
    format->mBytesPerPacket = 4;
}

static void setBufferSize(int samplerate, int preferredBufferSizeMs, AudioDeviceID deviceID) {
    if (samplerate < 1) return;
    UInt32 frames = powf(2.0f, floorf(log2f(float(samplerate) * 0.001f * float(preferredBufferSizeMs))));
    if (frames > 4096) frames = 4096;
    AudioObjectPropertyAddress address = { kAudioDevicePropertyBufferFrameSize, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    if (deviceID != UINT_MAX) AudioObjectSetPropertyData(deviceID, &address, 0, NULL, sizeof(UInt32), &frames);
}

- (void)setBufferSize {
    if (audioDeviceID != UINT_MAX) setBufferSize(samplerate, preferredBufferSizeMs, audioDeviceID);
    else {
        AudioDeviceID inputDevice = getDefaultAudioDevice(true), outputDevice = getDefaultAudioDevice(false);
        setBufferSize(samplerate, preferredBufferSizeMs, inputDevice);
        if (outputDevice != inputDevice) setBufferSize(samplerate, preferredBufferSizeMs, outputDevice);
    }
}

static bool hasMapping(int *map) {
    for (int n = 0; n < 32; n++) if (map[n] != -1) return true;
    return false;
}

- (void)mapChannels {
    if (!delegate || ![delegate respondsToSelector:@selector(mapChannels:numOutputChannels:outputMap:input:numInputChannels:inputMap:)]) return;
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(mapChannels) withObject:nil waitUntilDone:NO];
        return;
    }
    int inputMap[32], outputMap[32];
    for (int n = 0; n < 32; n++) inputMap[n] = outputMap[n] = -1;
    [delegate mapChannels:mapOutputDeviceName numOutputChannels:mapNumOutputChannels outputMap:outputMap input:mapInputDeviceName numInputChannels:mapNumInputChannels inputMap:inputMap];
    if (outputUnit && hasMapping(outputMap)) AudioUnitSetProperty(outputUnit, kAudioOutputUnitProperty_ChannelMap, kAudioUnitScope_Output, 0, outputMap, 128);
    if (inputUnit && hasMapping(inputMap)) AudioUnitSetProperty(inputUnit, kAudioOutputUnitProperty_ChannelMap, kAudioUnitScope_Output, 1, inputMap, 128);
}

- (void)createAudioUnits {
    destroyUnit(&inputUnit);
    destroyUnit(&outputUnit);

    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_HALOutput;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent component = AudioComponentFindNext(NULL, &desc);
    AudioUnit inau = NULL, outau = NULL;
    
    [mapInputDeviceName release];
    [mapOutputDeviceName release];
     mapInputDeviceName = mapOutputDeviceName = nil;
    AudioObjectPropertyAddress deviceNameAddress = { kAudioObjectPropertyName, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    AudioObjectPropertyAddress inputChannelsAddress = { kAudioDevicePropertyStreamConfiguration, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMaster };
    AudioObjectPropertyAddress outputChannelsAddress = { kAudioDevicePropertyStreamConfiguration, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMaster };
    mapNumInputChannels = mapNumOutputChannels = 0;
    
    if (outputEnabled) {
        if (!AudioComponentInstanceNew(component, &outau) && enableInput(outau, false) && enableOutput(outau, true)) {
            AudioDeviceID device = audioDeviceID != UINT_MAX ? audioDeviceID : getDefaultAudioDevice(false);
            if ((device != UINT_MAX) && !AudioUnitSetProperty(outau, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &device, sizeof(device))) {
                AudioUnitAddPropertyListener(outau, kAudioUnitProperty_StreamFormat, streamFormatChangedCallback, (__bridge void *)self);
                AudioStreamBasicDescription format;
                makeStreamFormat(outau, &format, false);
                if (format.mChannelsPerFrame > numberOfChannels) format.mChannelsPerFrame = numberOfChannels;
                samplerate = format.mSampleRate;
                format.mChannelsPerFrame = numberOfChannels;
                if (!AudioUnitSetProperty(outau, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format))) {
                    AURenderCallbackStruct callbackStruct;
                    callbackStruct.inputProc = audioOutputCallback;
                    callbackStruct.inputProcRefCon = (__bridge void *)self;
                    if (!AudioUnitSetProperty(outau, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct))) {
                        AudioUnitInitialize(outau);
                        outputUnit = outau;
                        outau = NULL;
                        
                        UInt32 size = sizeof(CFStringRef);
                        CFStringRef cstr = NULL;
                        AudioObjectGetPropertyData(device, &deviceNameAddress, 0, NULL, &size, &cstr);
                        mapOutputDeviceName = (NSString *)cstr;
                        if (!AudioObjectGetPropertyDataSize(device, &outputChannelsAddress, 0, NULL, &size)) {
                            AudioBufferList *bufferList = (AudioBufferList *)malloc(size);
                            if (bufferList) {
                                if (!AudioObjectGetPropertyData(device, &outputChannelsAddress, 0, NULL, &size, bufferList)) {
                                    for (int b = 0; b < bufferList->mNumberBuffers; b++) mapNumOutputChannels += bufferList->mBuffers[b].mNumberChannels;
                                }
                                free(bufferList);
                            }
                        }
                    };
                };
            };
        };
    };

    if (inputEnabled) {
        if (!AudioComponentInstanceNew(component, &inau) && enableInput(inau, true) && enableOutput(inau, false)) {
            AudioDeviceID device = audioDeviceID != UINT_MAX ? audioDeviceID : getDefaultAudioDevice(true);
            if ((device != UINT_MAX) && !AudioUnitSetProperty(inau, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &device, sizeof(device))) {
                AudioUnitAddPropertyListener(inau, kAudioUnitProperty_StreamFormat, streamFormatChangedCallback, (__bridge void *)self);
                AudioStreamBasicDescription format;
                makeStreamFormat(inau, &format, true);
                if (format.mChannelsPerFrame > numberOfChannels) format.mChannelsPerFrame = numberOfChannels;
                inputChannels = format.mChannelsPerFrame;
                if (outputEnabled) format.mSampleRate = samplerate; else samplerate = format.mSampleRate;
                format.mChannelsPerFrame = numberOfChannels;
                if (!AudioUnitSetProperty(inau, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &format, sizeof(format))) {
                    AURenderCallbackStruct callbackStruct;
                    callbackStruct.inputProc = audioInputCallback;
                    callbackStruct.inputProcRefCon = (__bridge void *)self;
                    if (!AudioUnitSetProperty(inau, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callbackStruct, sizeof(callbackStruct))) {
                        AudioUnitInitialize(inau);
                        inputUnit = inau;
                        inau = NULL;
                        
                        UInt32 size = sizeof(CFStringRef);
                        CFStringRef cstr = NULL;
                        AudioObjectGetPropertyData(device, &deviceNameAddress, 0, NULL, &size, &cstr);
                        mapInputDeviceName = (NSString *)cstr;
                        if (!AudioObjectGetPropertyDataSize(device, &inputChannelsAddress, 0, NULL, &size)) {
                            AudioBufferList *bufferList = (AudioBufferList *)malloc(size);
                            if (bufferList) {
                                if (!AudioObjectGetPropertyData(device, &inputChannelsAddress, 0, NULL, &size, bufferList)) {
                                    for (int b = 0; b < bufferList->mNumberBuffers; b++) mapNumInputChannels += bufferList->mBuffers[b].mNumberChannels;
                                }
                                free(bufferList);
                            }
                        }
                    };
                };
            };
        };
    };
    
    [self mapChannels];
    destroyUnit(&inau);
    destroyUnit(&outau);
    [self setBufferSize];
    if (self->shouldRun) [self start];
}

// public methods
- (bool)start {
    if (![NSThread isMainThread]) return false;
    shouldRun = true;
    if (!inputUnit && !outputUnit) return false;
    if (inputUnit && AudioOutputUnitStart(inputUnit)) return false;
    if (outputUnit && AudioOutputUnitStart(outputUnit)) return false;
    return true;
}

- (void)stop {
    if (![NSThread isMainThread]) [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    else {
        shouldRun = false;
        if (inputUnit) AudioOutputUnitStop(inputUnit);
        if (outputUnit) AudioOutputUnitStop(outputUnit);
    };
}

- (void)setInputEnabled:(bool)e {
    if (![NSThread isMainThread]) dispatch_async(dispatch_get_main_queue(), ^{ [self setInputEnabled:e]; });
    else if (inputEnabled != e) {
        self->inputEnabled = e;
        [self createAudioUnits];
    };
}

- (void)setOutputEnabled:(bool)e {
    if (![NSThread isMainThread]) dispatch_async(dispatch_get_main_queue(), ^{ [self setOutputEnabled:e]; });
    else if (outputEnabled != e) {
        self->outputEnabled = e;
        [self createAudioUnits];
    };
}

- (void)setAudioDevice:(unsigned int)deviceID {
    if (![NSThread isMainThread]) dispatch_async(dispatch_get_main_queue(), ^{
        if (audioDeviceID == deviceID) return;
        audioDeviceID = deviceID;
        [self createAudioUnits];
    }); else {
        if (audioDeviceID == deviceID) return;
        audioDeviceID = deviceID;
        [self createAudioUnits];
    }
}

- (void)setPreferredBufferSizeMs:(int)ms {
    preferredBufferSizeMs = ms;
    if ([NSThread isMainThread]) [self setBufferSize]; else [self performSelectorOnMainThread:@selector(setBufferSize) withObject:nil waitUntilDone:NO];
}

+ (audioDevice *)getAudioDevices {
    AudioObjectPropertyAddress allDevices = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    AudioObjectPropertyAddress deviceName = { kAudioObjectPropertyName, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    AudioObjectPropertyAddress inputChannels = { kAudioDevicePropertyStreamConfiguration, kAudioDevicePropertyScopeInput, kAudioObjectPropertyElementMaster };
    AudioObjectPropertyAddress outputChannels = { kAudioDevicePropertyStreamConfiguration, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMaster };
    
    UInt32 size = 0;
    if (AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &allDevices, 0, NULL, &size) || !size) return NULL;
    int numDevices = size / sizeof(AudioDeviceID);
    AudioDeviceID devices[numDevices];
    if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &allDevices, 0, NULL, &size, devices)) return NULL;
    
    CFStringRef name;
    size = sizeof(name);
    const char *cname;
    int numInputChannels, numOutputChannels;
    AudioBufferList *bufferList;
    audioDevice *result = NULL, *last = NULL, *current;
    
    for (int n = 0; n < numDevices; n++) {
        numInputChannels = numOutputChannels = 0;
        
        if (!AudioObjectGetPropertyDataSize(devices[n], &inputChannels, 0, NULL, &size)) {
            bufferList = (AudioBufferList *)malloc(size);
            if (bufferList) {
                if (!AudioObjectGetPropertyData(devices[n], &inputChannels, 0, NULL, &size, bufferList)) {
                    numInputChannels = 0;
                    for (int b = 0; b < bufferList->mNumberBuffers; b++) numInputChannels += bufferList->mBuffers[b].mNumberChannels;
                }
                free(bufferList);
            }
        }
        
        if (!AudioObjectGetPropertyDataSize(devices[n], &outputChannels, 0, NULL, &size)) {
            bufferList = (AudioBufferList *)malloc(size);
            if (bufferList) {
                if (!AudioObjectGetPropertyData(devices[n], &outputChannels, 0, NULL, &size, bufferList)) {
                    numOutputChannels = 0;
                    for (int b = 0; b < bufferList->mNumberBuffers; b++) numOutputChannels += bufferList->mBuffers[b].mNumberChannels;
                }
                free(bufferList);
            }
        }
        
        if (numInputChannels + numOutputChannels < 1) continue;
        size = sizeof(name);
        name = NULL;
        if (AudioObjectGetPropertyData(devices[n], &deviceName, 0, NULL, &size, &name) || !name) continue;
        
        cname = [(NSString *)name UTF8String];
        if (cname) {
            current = (audioDevice *)malloc(sizeof(audioDevice));
            if (current) {
                current->name = strdup(cname);
                if (!current->name) free(current);
                else {
                    current->next = NULL;
                    current->numInputChannels = numInputChannels;
                    current->numOutputChannels = numOutputChannels;
                    current->deviceID = devices[n];
                    
                    if (!result) result = current; else last->next = current;
                    last = current;
                }
            }
        }
        
        CFRelease(name);
    }
    
    return result;
}

@end
