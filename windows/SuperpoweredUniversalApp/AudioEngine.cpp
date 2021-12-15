
#include "pch.h"

#if _DEBUG
#define CONFIGURATION "Debug"
#else
#define CONFIGURATION "Release"
#endif
#if _M_ARM
#define PLATFORM "ARM"
#elif _M_X64
#define PLATFORM "x64"
#else
#define PLATFORM "x86"
#endif
#pragma comment(lib, "..\\..\\superpowered\\libWindows\\SuperpoweredWinUWP_" CONFIGURATION "_" PLATFORM  ".lib")


#include "AudioEngine.h"
#include <Superpowered.h>
#include <SuperpoweredSimple.h>
#include <SuperpoweredGenerator.h>
#include <OpenSource/SuperpoweredWindowsAudioIO.h>

static SuperpoweredWindowsAudioIO* audioIO = NULL;

static bool audioProcessing(void* clientdata, float* audio, int numberOfFrames, int samplerate) {
	AudioEngine *self = (AudioEngine*)clientdata;
	if (!audio) {
		return false;
	}
	bool hasOutput = self->getMixer()->process(audio, numberOfFrames, samplerate);
	if (!hasOutput) {
		memset(audio, 0, numberOfFrames * 2 * sizeof(float));
	}
	return true;
}

AudioEngine::AudioEngine(const char* pathA, const char* pathB)
{
	Superpowered::Initialize(
		"ExampleLicenseKey-WillExpire-OnNextUpdate",
		false, // enableAudioAnalysis (using SuperpoweredAnalyzer, SuperpoweredLiveAnalyzer, SuperpoweredWaveform or SuperpoweredBandpassFilterbank)
		false, // enableFFTAndFrequencyDomain (using SuperpoweredFrequencyDomain, SuperpoweredFFTComplex, SuperpoweredFFTReal or SuperpoweredPolarFFT)
		true, // enableAudioTimeStretching (using SuperpoweredTimeStretching)
		true, // enableAudioEffects (using any SuperpoweredFX class)
		true,  // enableAudioPlayerAndDecoder (using SuperpoweredAdvancedAudioPlayer or SuperpoweredDecoder)
		false, // enableCryptographics (using Superpowered::RSAPublicKey, Superpowered::RSAPrivateKey, Superpowered::hasher or Superpowered::AES)
		false  // enableNetworking (using Superpowered::httpRequest)
	);

	audioBuffer = (float*)malloc(sizeof(float) * 48000 * 2);

	MixerChannelAsset assetA = MixerChannelAsset();
	assetA.filePath = pathA;
	assetA.originalBPM = 126;
	assetA.firstBeatMs = 353;

	MixerChannelAsset assetB = MixerChannelAsset();
	assetB.filePath = pathB;
	assetB.originalBPM = 123;
	assetB.firstBeatMs = 40;

	mixerEngine = new MixerEngine(assetA, assetB);

	audioIO = new SuperpoweredWindowsAudioIO(audioProcessing, (void*)this, false, true);
};

AudioEngine::~AudioEngine()
{
	audioIO->stop();
	delete mixerEngine;
	free(audioBuffer);
}

void AudioEngine::start()
{
	audioIO->start();
}

float* AudioEngine::getAudioBuffer()
{
	return audioBuffer;
}

MixerEngine* AudioEngine::getMixer()
{
	return mixerEngine;
}