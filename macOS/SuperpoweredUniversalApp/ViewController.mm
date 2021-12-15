//
//  ViewController.m
//  SuperpoweredMacOSBoilerplate
//
//  Created by Balázs Kiss and Thomas Dodds on 2021. 10. 21..
//

#import "ViewController.h"
#import <atomic>
#import "AudioEngineMacOS.h"

@interface ViewController ()

@property (nonatomic, strong) AudioEngineMacOS *audioEngine;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController {
    std::atomic<float> channel0Volume, channel1Volume,
    tempo, crossFaderPosition,
    channel0Roll, channel1Roll;
    std::atomic<int> channel0PitchShift, channel1PitchShift;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _audioEngine = [[AudioEngineMacOS alloc] init];
    }
    return self;
}

- (void)animate {
    //get calculated audiolevels from the audio engine and update rectangle height based on it.
    NSRect mainMeter = self.masterPeakMeter.frame;
    mainMeter.size.height = 420 * self.audioEngine.peak;
    self.masterPeakMeter.frame = mainMeter;
    
    NSRect ch0Meter = self.ch0PeakMeter.frame;
    ch0Meter.size.height = 420 * [self.audioEngine peakForChannel:0];
    self.ch0PeakMeter.frame = ch0Meter;
    
    NSRect ch1Meter = self.ch1PeakMeter.frame;
    ch1Meter.size.height = 420 * [self.audioEngine peakForChannel:1];
    self.ch1PeakMeter.frame = ch1Meter;
}

- (void)setInitialValues {
    channel0Volume = 0.8;
    channel1Volume = 0.8;
    tempo = 126;
    crossFaderPosition = 0.5;
    channel0PitchShift = 0;
    channel1PitchShift = 0;
    channel0Roll = 0;
    channel1Roll = 0;
    [self.audioEngine setTempo:tempo];
    [self.audioEngine setCrossFaderPosition:crossFaderPosition];
    [self.audioEngine setVolume:channel0Volume channel:0];
    [self.audioEngine setVolume:channel1Volume channel:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setInitialValues];
    
    // Start Meter animaion loop (100fps)
    self.timer = [NSTimer timerWithTimeInterval:1.0/100.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (IBAction)ch0VolumeSliderAction:(id)sender {
    [self.audioEngine setVolume:[sender floatValue] channel: 0];
}

- (IBAction)ch0FilterFrequencySliderAction:(id)sender {
    [self.audioEngine setFilterFrequencyPosition:[sender floatValue] channel: 0];
}

- (IBAction)ch0RollTwoAction:(id)sender {
    if (channel0Roll == 2) {
        [self.audioEngine setRollDisabledForChannel:0];
        channel0Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:2 channel: 0];
        channel0Roll = 2;
        self.ch0RollOneButton.state = false;
        self.ch0RollHalfButton.state = false;
        self.ch0RollQuarterButton.state = false;
    }
}

- (IBAction)ch0RollOneAction:(id)sender {
    if (channel0Roll == 1) {
        [self.audioEngine setRollDisabledForChannel:0];
        channel0Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:1 channel: 0];
        channel0Roll = 1;
        self.ch0RollTwoButton.state = false;
        self.ch0RollHalfButton.state = false;
        self.ch0RollQuarterButton.state = false;
    }
}

- (IBAction)ch0RollHalfAction:(id)sender {
    if (channel0Roll == 0.5) {
        [self.audioEngine setRollDisabledForChannel: 0];
        channel0Roll = 0;
    } else {
        [self.audioEngine setRollEnabled: 0.5 channel: 0];
        channel0Roll = 0.5;
        self.ch0RollTwoButton.state = false;
        self.ch0RollOneButton.state = false;
        self.ch0RollQuarterButton.state = false;
    }
}

- (IBAction)ch0RollQuarterAction:(id)sender {
    if (channel0Roll == 0.25) {
        [self.audioEngine setRollDisabledForChannel:0];
        channel0Roll = 0;
    } else {
        [self.audioEngine setRollEnabled: 0.25 channel: 0];
        channel0Roll = 0.25;
        self.ch0RollTwoButton.state = false;
        self.ch0RollHalfButton.state = false;
        self.ch0RollOneButton.state = false;
    }
}

- (IBAction)ch0PichDownAction:(id)sender {
    int newPitchShift = [self.audioEngine pitchShiftForChannel: 0] - 1;
    [self.audioEngine setPitchShift:newPitchShift channel: 0];
    channel0PitchShift = newPitchShift;
    self.ch0PitchLabel.stringValue = [NSString stringWithFormat:@"%.1d", newPitchShift];
}

- (IBAction)ch0PitchUpAction:(id)sender {
    int newPitchShift = [self.audioEngine pitchShiftForChannel: 0] + 1;
    [self.audioEngine setPitchShift:newPitchShift channel: 0];
    channel0PitchShift = newPitchShift;
    self.ch0PitchLabel.stringValue = [NSString stringWithFormat:@"%.1d", newPitchShift];
}

- (IBAction)ch1VolumeSliderAction:(id)sender {
    [self.audioEngine setVolume:[sender floatValue] channel: 1];
}

- (IBAction)ch1FilterFrequencySliderAcion:(id)sender {
    [self.audioEngine setFilterFrequencyPosition:[sender floatValue] channel: 1];
}

- (IBAction)ch1RollTwoAction:(id)sender {
    if (channel1Roll == 2) {
        [self.audioEngine setRollDisabledForChannel:1];
        channel1Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:2 channel: 1];
        channel1Roll = 2;
        self.ch1RollOneButton.state = false;
        self.ch1RollHalfButton.state = false;
        self.ch1RollQuarterButton.state = false;
    }
}

- (IBAction)ch1RollOneAction:(id)sender {
    if (channel1Roll == 1) {
        [self.audioEngine setRollDisabledForChannel:1];
        channel1Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:1 channel: 1];
        channel1Roll = 1;
        self.ch1RollTwoButton.state = false;
        self.ch1RollHalfButton.state = false;
        self.ch1RollQuarterButton.state = false;
    }
}

- (IBAction)ch1RollHalfAction:(id)sender {
    if (channel1Roll == 0.5) {
        [self.audioEngine setRollDisabledForChannel:1];
        channel1Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:0.5 channel: 1];
        channel1Roll = 0.5;
        self.ch1RollTwoButton.state = false;
        self.ch1RollOneButton.state = false;
        self.ch1RollQuarterButton.state = false;
    }
}

- (IBAction)ch1RollQuarterAction:(id)sender {
    if (channel1Roll == 0.25) {
        [self.audioEngine setRollDisabledForChannel:1];
        channel1Roll = 0;
    } else {
        [self.audioEngine setRollEnabled:0.25 channel: 1];
        channel1Roll = 0.25;
        self.ch1RollTwoButton.state = false;
        self.ch1RollHalfButton.state = false;
        self.ch1RollOneButton.state = false;
    }
}

- (IBAction)ch1PitchDownAction:(id)sender {
    int newPitchShift = [self.audioEngine pitchShiftForChannel:1] - 1;
    [self.audioEngine setPitchShift:newPitchShift channel: 1];
    channel1PitchShift = newPitchShift;
    self.ch1PitchLabel.stringValue = [NSString stringWithFormat:@"%.1d", newPitchShift];
    
}

- (IBAction)ch1PitchUpAction:(id)sender {
    int newPitchShift = [self.audioEngine pitchShiftForChannel: 1] + 1;
    [self.audioEngine setPitchShift:newPitchShift channel: 1];
    channel0PitchShift = newPitchShift;
    self.ch1PitchLabel.stringValue = [NSString stringWithFormat:@"%.1d", newPitchShift];
}

- (IBAction)startStopButtonAction:(id)sender {
    [self.audioEngine togglePlay];
}

- (IBAction)tempoSliderAction:(id)sender {
    [self.audioEngine setTempo:[sender floatValue]];
}

- (IBAction)crossfaderSliderAction:(id)sender {
    [self.audioEngine setCrossFaderPosition:[sender floatValue]];
}

@end
