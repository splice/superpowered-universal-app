//
// MainPage.xaml.cpp
// Implementation of the MainPage class.
//

#include "pch.h"
#include "MainPage.xaml.h"

using namespace SuperpoweredUniversalApp;

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Media;
using namespace Windows::UI::Xaml::Navigation;
using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Media;
using namespace Windows::UI::Xaml::Navigation;


// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

#define stringToChar(path, cpath) cpath[WideCharToMultiByte(CP_UTF8, 0, path->Data(), -1, cpath, MAX_PATH + 1, NULL, NULL)] = 0;

MainPage::MainPage()
{
	rollChannel0 = 0;
	rollChannel1 = 0;

	char pathA[MAX_PATH + 1];
	stringToChar(Windows::ApplicationModel::Package::Current->InstalledLocation->Path, pathA);
	sprintf_s(pathA, MAX_PATH + 1, "%s\\lycka.mp3", pathA);

	char pathB[MAX_PATH + 1];
	stringToChar(Windows::ApplicationModel::Package::Current->InstalledLocation->Path, pathB);
	sprintf_s(pathB, MAX_PATH + 1, "%s\\nuyorica.m4a", pathB);
	
	audioEngine = new AudioEngine(pathA, pathB);
	audioEngine->start();

	InitializeComponent();

	PitchChannel0->Content = "0";
	PitchChannel1->Content = "0";

	GainChannel0->Value = 0;
	GainChannel1->Value = 0;
	GainMaster->Value = 0;

	DispatcherTimer^ timer = ref new DispatcherTimer;
	timer->Tick += ref new Windows::Foundation::EventHandler<Platform::Object^>(this, &SuperpoweredUniversalApp::MainPage::DispatcherTimer_Tick);
	TimeSpan t;
	t.Duration = 100000;
	timer->Interval = t;
	timer->Start();
}

MainPage::~MainPage()
{
	delete audioEngine;
}

void SuperpoweredUniversalApp::MainPage::DispatcherTimer_Tick(Platform::Object^ sender, Platform::Object^ e)
{
	GainChannel0->Value = audioEngine->getMixer()->getChannelPeak(0);
	GainChannel1->Value = audioEngine->getMixer()->getChannelPeak(1);
	GainMaster->Value = audioEngine->getMixer()->getPeak();
}

void SuperpoweredUniversalApp::MainPage::Crossfader_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setCrossFaderPosition(e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::Tempo_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setTempo(e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::GainChannel0_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setChannelVolume(0, e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::GainChannel1_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setChannelVolume(1, e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::FilterChannel0_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setChannelFilterFrequencyPosition(0, e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::FilterChannel1_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e)
{
	audioEngine->getMixer()->setChannelFilterFrequencyPosition(1, e->NewValue);
}

void SuperpoweredUniversalApp::MainPage::updateButtonStyle(Windows::UI::Xaml::Controls::Button^ button, bool selected)
{
	auto whiteColor = Windows::UI::ColorHelper::FromArgb(255, 255, 255, 255);
	auto blueColor = Windows::UI::ColorHelper::FromArgb(255, 0, 120, 212);
	button->Background = ref new SolidColorBrush(selected ? blueColor : whiteColor);
	button->Foreground = ref new SolidColorBrush(selected ? whiteColor : blueColor);
}

void SuperpoweredUniversalApp::MainPage::updateChannel0Roll(float newValue)
{
	if (rollChannel0 == newValue) {
		rollChannel0 = 0;
	}
	else {
		rollChannel0 = newValue;
	}
	if (rollChannel0 == 0) {
		audioEngine->getMixer()->setChannelRollDisable(0);
	}
	else {
		audioEngine->getMixer()->setChannelRollEnabled(0, rollChannel0);
	}
	updateButtonStyle(Roll1Channel0, rollChannel0 == 2.0);
	updateButtonStyle(Roll2Channel0, rollChannel0 == 1.0);
	updateButtonStyle(Roll3Channel0, rollChannel0 == 0.5);
	updateButtonStyle(Roll4Channel0, rollChannel0 == 0.25);
}

void SuperpoweredUniversalApp::MainPage::updateChannel1Roll(float newValue)
{
	if (rollChannel1 == newValue) {
		rollChannel1 = 0;
	}
	else {
		rollChannel1 = newValue;
	}
	if (rollChannel1 == 0) {
		audioEngine->getMixer()->setChannelRollDisable(1);
	}
	else {
		audioEngine->getMixer()->setChannelRollEnabled(1, rollChannel1);
	}
	updateButtonStyle(Roll1Channel1, rollChannel1 == 2.0);
	updateButtonStyle(Roll2Channel1, rollChannel1 == 1.0);
	updateButtonStyle(Roll3Channel1, rollChannel1 == 0.5);
	updateButtonStyle(Roll4Channel1, rollChannel1 == 0.25);
}

void SuperpoweredUniversalApp::MainPage::Roll1Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel0Roll(2.0);
}

void SuperpoweredUniversalApp::MainPage::Roll2Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel0Roll(1.0);
}

void SuperpoweredUniversalApp::MainPage::Roll3Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel0Roll(0.5);
}

void SuperpoweredUniversalApp::MainPage::Roll4Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel0Roll(0.25);
}

void SuperpoweredUniversalApp::MainPage::Roll1Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel1Roll(2.0);
}

void SuperpoweredUniversalApp::MainPage::Roll2Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel1Roll(1.0);
}

void SuperpoweredUniversalApp::MainPage::Roll3Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel1Roll(0.5);
}

void SuperpoweredUniversalApp::MainPage::Roll4Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	updateChannel1Roll(0.25);
}

void SuperpoweredUniversalApp::MainPage::PitchLowerChannel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	int pitch = audioEngine->getMixer()->getChannelPitchShift(0);
	audioEngine->getMixer()->setChannelPitchShift(0, pitch - 1);
	pitch = audioEngine->getMixer()->getChannelPitchShift(0);
	PitchChannel0->Content = pitch;
}

void SuperpoweredUniversalApp::MainPage::PitchRaiseChannel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	int pitch = audioEngine->getMixer()->getChannelPitchShift(0);
	audioEngine->getMixer()->setChannelPitchShift(0, pitch + 1);
	pitch = audioEngine->getMixer()->getChannelPitchShift(0);
	PitchChannel0->Content = pitch;
}

void SuperpoweredUniversalApp::MainPage::PitchLowerChannel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	int pitch = audioEngine->getMixer()->getChannelPitchShift(1);
	audioEngine->getMixer()->setChannelPitchShift(1, pitch - 1);
	pitch = audioEngine->getMixer()->getChannelPitchShift(1);
	PitchChannel1->Content = pitch;
}

void SuperpoweredUniversalApp::MainPage::PitchRaiseChannel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	int pitch = audioEngine->getMixer()->getChannelPitchShift(1);
	audioEngine->getMixer()->setChannelPitchShift(1, pitch + 1);
	pitch = audioEngine->getMixer()->getChannelPitchShift(1);
	PitchChannel1->Content = pitch;
}


void SuperpoweredUniversalApp::MainPage::Button_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	audioEngine->getMixer()->togglePlay();
}


void SuperpoweredUniversalApp::MainPage::TextBlock_SelectionChanged(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{

}
