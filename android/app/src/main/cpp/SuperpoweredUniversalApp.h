#ifndef Header_SuperpoweredUniversalApp
#define Header_SuperpoweredUniversalApp

#include <math.h>
#include <pthread.h>
#include <OpenSource/SuperpoweredAndroidAudioIO.h>
#include <Superpowered.h>
#include <SuperpoweredGenerator.h>
#include "MixerEngine.hpp"

class SuperpoweredUniversalApp {
public:
	MixerEngine *mixer;

	SuperpoweredUniversalApp(unsigned int samplerate, unsigned int buffersize, const char *path, int fileAOffset, int fileALength, int fileBOffset, int fileBLength);
	~SuperpoweredUniversalApp();

	bool process(short int *output, unsigned int numberOfSamples, unsigned int samplerate);

private:
	SuperpoweredAndroidAudioIO *outputIO;
	Superpowered::Generator *generator;
};

#endif
