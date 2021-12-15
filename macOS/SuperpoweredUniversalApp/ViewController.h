//
//  ViewController.h
//  SuperpoweredMacOSBoilerplate
//
//  Created by Balázs Kiss on 2021. 10. 21..
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSSlider *ch0VolumeSlider;
@property (weak) IBOutlet NSSlider *ch0FilterFrequencySlider;
@property (weak) IBOutlet NSButton *ch0RollTwoButton;
@property (weak) IBOutlet NSButton *ch0RollOneButton;
@property (weak) IBOutlet NSButton *ch0RollHalfButton;
@property (weak) IBOutlet NSButton *ch0RollQuarterButton;
@property (weak) IBOutlet NSButton *ch0PitchDownButton;
@property (weak) IBOutlet NSButton *ch0PichUpButton;
@property (weak) IBOutlet NSTextField *ch0PitchLabel;
@property (weak) IBOutlet NSBox *ch0PeakMeter;

@property (weak) IBOutlet NSSlider *ch1VolumeSlider;
@property (weak) IBOutlet NSSlider *ch1FilerFrequencySlider;
@property (weak) IBOutlet NSButton *ch1RollTwoButton;
@property (weak) IBOutlet NSButton *ch1RollOneButton;
@property (weak) IBOutlet NSButton *ch1RollHalfButton;
@property (weak) IBOutlet NSButton *ch1RollQuarterButton;
@property (weak) IBOutlet NSButton *ch1PitchDownButon;
@property (weak) IBOutlet NSButton *ch1PitchUpButton;
@property (weak) IBOutlet NSTextField *ch1PitchLabel;
@property (weak) IBOutlet NSBox *ch1PeakMeter;

@property (weak) IBOutlet NSSlider *tempoSlider;
@property (weak) IBOutlet NSSlider *crossFaderSlider;
@property (weak) IBOutlet NSBox *masterPeakMeter;

@end

