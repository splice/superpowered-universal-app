#pragma once

#include "MixerEngine.hpp"

class AudioEngine
{
public:
	AudioEngine(const char *pathA, const char *pathB);
	~AudioEngine();
	void start();
	float* getAudioBuffer();
	MixerEngine* getMixer();
private:
	float* audioBuffer;
	MixerEngine* mixerEngine;
};

