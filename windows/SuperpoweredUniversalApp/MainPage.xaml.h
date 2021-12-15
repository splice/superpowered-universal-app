//
// MainPage.xaml.h
// Declaration of the MainPage class.
//

#pragma once

#include "MainPage.g.h"
#include "AudioEngine.h"

namespace SuperpoweredUniversalApp
{
	/// <summary>
	/// An empty page that can be used on its own or navigated to within a Frame.
	/// </summary>
	public ref class MainPage sealed
	{
	public:
		MainPage();
		virtual ~MainPage();

	private:
		AudioEngine *audioEngine;
		float rollChannel0;
		float rollChannel1;

		void DispatcherTimer_Tick(Platform::Object^ sender, Platform::Object^ e);

		void Crossfader_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);
		void Tempo_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);
		void GainChannel0_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);
		void GainChannel1_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);
		void FilterChannel0_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);
		void FilterChannel1_ValueChanged(Platform::Object^ sender, Windows::UI::Xaml::Controls::Primitives::RangeBaseValueChangedEventArgs^ e);

		void updateButtonStyle(Windows::UI::Xaml::Controls::Button^ button, bool selected);
		void updateChannel0Roll(float newValue);
		void updateChannel1Roll(float newValue);
		void Roll1Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll2Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll3Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll4Channel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll1Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll2Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll3Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Roll4Channel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);

		void PitchLowerChannel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void PitchRaiseChannel0_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void PitchLowerChannel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void PitchRaiseChannel1_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void Button_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void TextBlock_SelectionChanged(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
	};
};
