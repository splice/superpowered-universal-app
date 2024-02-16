//
//  ContentView.swift
//  Shared
//
//  Created by Balázs Kiss and Thomas Dodds on 2021. 11. 22..
//

import SwiftUI

struct ContentView: View {
    let audioEngine = AudioEngineIOS()
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State private var channel0Volume: Float = 0.8;
    @State private var channel1Volume: Float = 0.8;
    @State private var peak: Float = 0
    @State private var channel0Peak: Float = 0
    @State private var channel1Peak: Float = 0
    @State private var tempo: Float = 126
    @State private var crossFaderPosition: Float = 0.5
    @State private var channel0PitchShift: Int = 0
    @State private var channel1PitchShift: Int = 0
    @State private var channel0FilterFrequencyPosition: Float = 0.5
    @State private var channel1FilterFrequencyPosition: Float = 0.5
    @State private var channel0Roll: Float = 0
    @State private var channel1Roll: Float = 0

    @State private var showInfoDialog = false

    private var volumeSliderHeight: CGFloat = 250
    private var filterSliderHeight: CGFloat = 95
    private var channelMeterHeight: CGFloat = 250
    private var masterMeterHeight: CGFloat = 350
    private var sliderWidth: CGFloat = 25
    private var progressWidth: CGFloat = 10
    private var buttonFontSize: CGFloat = 14
    var body: some View {

        VStack(alignment: .center) {
            HStack {
                Spacer()
                Spacer()
                Image("superpoweredLogo")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200.0, height: 30)
                Spacer()
                Button(action: {
                    showInfoDialog.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
            HStack(alignment: .bottom) {
                VStack {
                    HStack {
                    VStack {
                        
                        VStack {
                            Text("ROLL").font(.caption)
                            Button("2", action: {
                                if channel0Roll == 2 {
                                                                         audioEngine.setRollDisabledForChannel(0)
                                    channel0Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(2, channel: 0)
                                    channel0Roll = 2
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel0Roll == 2 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel0Roll == 2 ? Color.white : Color.blue)
                            Button("1", action: {
                                if channel0Roll == 1 {
                                                                         audioEngine.setRollDisabledForChannel(0)
                                    channel0Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1, channel: 0)
                                    channel0Roll = 1
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel0Roll == 1 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel0Roll == 1 ? Color.white : Color.blue)
                            Button("1/2", action: {
                                if channel0Roll == 1/2 {
                                                                         audioEngine.setRollDisabledForChannel(0)
                                    channel0Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1/2, channel: 0)
                                    channel0Roll = 1/2
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel0Roll == 1/2 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel0Roll == 1/2 ? Color.white : Color.blue)
                            Button("1/4", action: {
                                if channel0Roll == 1/4 {
                                                                         audioEngine.setRollDisabledForChannel(0)
                                    channel0Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1/4, channel: 0)
                                    channel0Roll = 1/4
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel0Roll == 1/4 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel0Roll == 1/4 ? Color.white : Color.blue)
                        }
                        VStack {
                            Text("HP").font(.caption)
                            ZStack {
                                Slider(value: $channel0FilterFrequencyPosition)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: filterSliderHeight, height: sliderWidth, alignment: .center)
                                    .onChange(of: self.channel0FilterFrequencyPosition) { newValue in
                                                                                 audioEngine.setFilterFrequencyPosition(Float(newValue), channel: 0)
                                    }
                            }.frame(width: sliderWidth, height: filterSliderHeight, alignment: .center)
                            Text("LP").font(.caption)
                        }
                        
                    }
                    VStack {
                        Text("A").font(.caption)
                        ZStack {
                            Slider(value: $channel0Volume)
                                .rotationEffect(.degrees(-90))
                                .frame(width: volumeSliderHeight, height: sliderWidth, alignment: .center)
                                .onChange(of: self.channel0Volume) { newValue in
                                                                         audioEngine.setVolume(Float(newValue), channel: 0);
                                }
                        }.frame(width: sliderWidth, height: volumeSliderHeight, alignment: .center)
                    }
                    ZStack {
                        ProgressView(value: channel0Peak)
                            .rotationEffect(.degrees(-90))
                            .frame(width: volumeSliderHeight, height: progressWidth, alignment: .center)
                                                .onReceive(timer) { _ in
                                                    channel0Peak = audioEngine.peak(forChannel: 0)
                                                }
                            .id(UUID())
                    }.frame(width: progressWidth, height: channelMeterHeight, alignment: .center)
                    }
                    VStack {
                        VStack {
                            Text("Pitch").font(.caption)
                            HStack {
                                Button("-1", action: {
                                                                     let newPitchShift = audioEngine.pitchShift(forChannel: 0) - 1
                                                                     audioEngine.setPitchShift(newPitchShift, channel: 0)
                                                                     channel0PitchShift = Int(newPitchShift)
                                }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            
                                            .stroke(Color.blue, lineWidth: 1))
                                        .background(Color.white) // If you have this
                                        .cornerRadius(15)
                                        .font(.caption2).foregroundColor(Color.blue)
                                Text("\(channel0PitchShift)").font(.caption2)
                                Button("+1", action: {
                                                                     let newPitchShift = audioEngine.pitchShift(forChannel: 0) + 1
                                                                     audioEngine.setPitchShift(newPitchShift, channel: 0)
                                                                     channel0PitchShift = Int(newPitchShift)
                                }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            
                                            .stroke(Color.blue, lineWidth: 1))
                                        .background(Color.white) // If you have this
                                        .cornerRadius(15)
                                        .font(.caption2).foregroundColor(Color.blue)
                            }
                        }
                    }
                }.padding(10.0).background(
                    Color.white
                ).overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 0.075, green: 0.325, blue: 0.998), lineWidth: 1)
                ).cornerRadius(15)
            
                VStack {
                    ProgressView(value: peak)
                        .rotationEffect(.degrees(-90))
                        .frame(width: masterMeterHeight, height: progressWidth, alignment: .center)
                                            .onReceive(timer) { _ in
                                                peak = audioEngine.peak();
                                            }
                        .id(UUID())
                }
                .frame(width: progressWidth ,height: masterMeterHeight, alignment: .center
                )
                VStack {
                HStack {
                    ZStack {
                        ProgressView(value: channel1Peak)
                            .rotationEffect(.degrees(-90))
                            .frame(width: volumeSliderHeight, height: progressWidth, alignment: .center)
                                                .onReceive(timer) { _ in
                                                    channel1Peak = audioEngine.peak(forChannel: 1)
                                                }
                            .id(UUID())
                    }.frame(width: progressWidth, height: channelMeterHeight, alignment: .center)
                    VStack {
                        Text("B").font(.caption)
                            .font(.caption)
                        ZStack {
                            Slider(value: $channel1Volume)
                                .rotationEffect(.degrees(-90))
                                .frame(width: volumeSliderHeight, height: sliderWidth, alignment: .center)
                                .onChange(of: self.channel1Volume) { newValue in
                                                                         audioEngine.setVolume(Float(newValue), channel: 1);
                                }
                        }.frame(width: sliderWidth, height: volumeSliderHeight, alignment: .center)
                    }
                    VStack {
                        VStack {
                            Text("ROLL").font(.caption)
                            Button("2", action: {
                                if channel1Roll == 2 {
                                                                         audioEngine.setRollDisabledForChannel(1)
                                    channel1Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(2, channel: 1)
                                    channel1Roll = 2
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel1Roll == 2 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel1Roll == 2 ? Color.white : Color.blue)
                            
                            Button("1", action: {
                                if channel1Roll == 1 {
                                                                         audioEngine.setRollDisabledForChannel(1)
                                    channel1Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1, channel: 1)
                                    channel1Roll = 1
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel1Roll == 1 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel1Roll == 1 ? Color.white : Color.blue)
                            
                            Button("1/2", action: {
                                if channel1Roll == 1/2 {
                                                                         audioEngine.setRollDisabledForChannel(1)
                                    channel1Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1/2, channel: 1)
                                    channel1Roll = 1/2
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel1Roll == 1/2 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel1Roll == 1/2 ? Color.white : Color.blue)
                            
                            
                            Button("1/4", action: {
                                if channel1Roll == 1/4 {
                                                                         audioEngine.setRollDisabledForChannel(1)
                                    channel1Roll = 0
                                } else {
                                                                         audioEngine.setRollEnabled(1/4, channel: 1)
                                    channel1Roll = 1/4
                                }
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(self.channel1Roll == 1/4 ? Color.blue : Color.white ) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption).foregroundColor(self.channel1Roll == 1/4 ? Color.white : Color.blue)
                
                        }
                        VStack {
                            Text("HP").font(.caption)
                            ZStack {
                                Slider(value: $channel1FilterFrequencyPosition)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: filterSliderHeight, height: sliderWidth, alignment: .center)
                                    .onChange(of: self.channel1FilterFrequencyPosition) { newValue in
                                                                             audioEngine.setFilterFrequencyPosition(Float(newValue), channel: 1)
                                    }
                            }.frame(width: sliderWidth, height: filterSliderHeight, alignment: .center)
                            Text("LP").font(.caption)
                        }
                    }
                }
                    VStack {
                        Text("Pitch").font(.caption)
                        HStack {
                            Button("-1", action: {
                                                                 let newPitchShift = audioEngine.pitchShift(forChannel: 1) - 1
                                                                 audioEngine.setPitchShift(newPitchShift, channel: 1)
                                                                 channel1PitchShift = Int(newPitchShift)
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(Color.white) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption2).foregroundColor(Color.blue)
                            Text("\(channel1PitchShift)").font(.caption2)
                            Button("+1", action: {
                                                                 let newPitchShift = audioEngine.pitchShift(forChannel: 1) + 1
                                                                 audioEngine.setPitchShift(newPitchShift, channel: 1)
                                                                 channel1PitchShift = Int(newPitchShift)
                            }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        
                                        .stroke(Color.blue, lineWidth: 1))
                                    .background(Color.white) // If you have this
                                    .cornerRadius(15)
                                    .font(.caption2).foregroundColor(Color.blue)
                        }
                    }
                }.padding(10).background(
                    Color.white
                ).overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(red: 0.075, green: 0.325, blue: 0.998), lineWidth: 1)
                ).cornerRadius(15)
            }
            
            
            VStack {
                VStack {
                    Text("Tempo").font(.caption)
                    Slider(value: $tempo, in: 80...150)
                        .onChange(of: self.tempo) { newValue in
                                                         audioEngine.setTempo(newValue)
                        }
                }.padding(5).background(
                    Color.white
                ).cornerRadius(15)
                VStack {
                    Text("Crossfader").font(.caption)
                    Slider(value: $crossFaderPosition, in: 0...1, step:0.001)
                        .onChange(of: self.crossFaderPosition) { newValue in
                                                         audioEngine.setCrossFaderPosition(newValue)
                        }
                    Button("Start / Stop", action: {
                                                 audioEngine.togglePlay()
                    }).padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)).overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue, lineWidth: 1)).padding(5)
                        .background(Color.white) // If you have this
                        .cornerRadius(15)
                }.padding(5).background(
                    Color.white
                ).cornerRadius(15)

            }
        }
        .alert(isPresented: $showInfoDialog) {
                    Alert(title: Text("Music Credits"), message: Text("ＭＩＬＬＥＮＮＩＡＬＳ by cdk (c) copyright 2018 Licensed under a Creative Commons Attribution (3.0) license.\nhttps://dig.ccmixter.org/files/cdk/57150\n\nI Have Often Told You Stories (guitar instrumental) by Ivan Chew (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license.\nhttps://dig.ccmixter.org/files/ramblinglibrarian/41284"), dismissButton: .default(Text("Close")))
                }
        .padding(20.0)
        .background(
            Image("bg"),

            alignment: .bottom
        ).scaledToFit();
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
