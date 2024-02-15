#include "SuperpoweredUniversalApp.h"
#include <Superpowered.h>
#include <SuperpoweredSimple.h>
#include <SuperpoweredCPU.h>
#include <jni.h>
#include <android/log.h>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

// Audio callback function. Called by the audio engine.
static bool audioProcessing (
		void *clientdata,	// A custom pointer your callback receives.
		short int *audioIO,	// 16-bit stereo interleaved audio input and/or output.
		int numFrames,		// The number of frames received and/or requested.
		int samplerate	    // The current sample rate in Hz.
) {
	return ((SuperpoweredUniversalApp *)clientdata)->process(audioIO, (unsigned int)numFrames, (unsigned int)samplerate);
}

SuperpoweredUniversalApp::SuperpoweredUniversalApp (
		unsigned int samplerate, // device native sample rate
		unsigned int buffersize, // device native buffer size
		const char *path,        // path to APK package
		int fileAOffset,
		int fileALength,
		int fileBOffset,
		int fileBLength
)
{
	Superpowered::Initialize("ExampleLicenseKey-WillExpire-OnNextUpdate");

	MixerChannelAsset assetA = MixerChannelAsset();
	assetA.filePath = path;
	assetA.fileOffset = fileAOffset;
	assetA.fileLength = fileALength;
	assetA.originalBPM = 100;
	assetA.firstBeatMs = 31;

	MixerChannelAsset assetB = MixerChannelAsset();
	assetB.filePath = path;
	assetB.fileOffset = fileBOffset;
	assetB.fileLength = fileBLength;
	assetB.originalBPM = 100;
	assetB.firstBeatMs = 1836;

	mixer = new MixerEngine(assetA, assetB);

	// Initialize audio engine and pass callback function.
	outputIO = new SuperpoweredAndroidAudioIO (
			samplerate,                     // device native sample rate
			buffersize,                     // device native buffer size
			false,                          // enableInput
			true,                           // enableOutput
			audioProcessing,                // audio callback function
			this,                           // clientData
			-1,                             // inputStreamType (-1 = default)
			SL_ANDROID_STREAM_MEDIA         // outputStreamType (-1 = default)
	);

	Superpowered::CPU::setSustainedPerformanceMode(true);
}

// Destructor. Free resources.
SuperpoweredUniversalApp::~SuperpoweredUniversalApp() {
	delete outputIO; // Always stop and delete audio I/O first.
	delete mixer;
}

// Main process function where audio is generated.
bool SuperpoweredUniversalApp::process(short int *output, unsigned int numberOfFrames, unsigned int samplerate) {
	float outputFloat[numberOfFrames * 2];
	bool hasOutput = mixer->process(outputFloat, numberOfFrames, samplerate);
	if (hasOutput) {
		Superpowered::FloatToShortInt(outputFloat, output, numberOfFrames, 2);
	}
	return hasOutput;
}

static SuperpoweredUniversalApp *example = NULL;

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_SuperpoweredUniversalApp(
		JNIEnv *env,
		jobject __unused obj,
		jint samplerate,  // device native sample rate
		jint buffersize,  // device native buffer size
		jstring apkPath,  // path to APK package
		jint fileAoffset, // offset of file A in APK
		jint fileAlength, // length of file A
		jint fileBoffset, // offset of file B in APK
		jint fileBlength  // length of file B
) {
	const char *path = env->GetStringUTFChars(apkPath, JNI_FALSE);
	example = new SuperpoweredUniversalApp((unsigned int)samplerate, (unsigned int)buffersize, path, fileAoffset, fileAlength, fileBoffset, fileBlength);
	env->ReleaseStringUTFChars(apkPath, path);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerTogglePlay(
        JNIEnv *env,
        jobject __unused obj
) {
	example->mixer->togglePlay();
}

extern "C" JNIEXPORT float
Java_com_superpowered_universalpapp_MainActivity_MixerGetPeak(
		JNIEnv *env,
		jobject __unused obj
) {
	return example->mixer->getPeak();
}

extern "C" JNIEXPORT float
Java_com_superpowered_universalpapp_MainActivity_MixerGetPeakForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel
) {
	return example->mixer->getChannelPeak(channel);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetCrossFaderPosition(
		JNIEnv *env,
		jobject __unused obj,
		float newValue
) {
	example->mixer->setCrossFaderPosition(newValue);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetTempo(
		JNIEnv *env,
		jobject __unused obj,
		float newValue
) {
	example->mixer->setTempo(newValue);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetFilterFrequencyPositionForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel,
		float newValue
) {
	example->mixer->setChannelFilterFrequencyPosition(channel, newValue);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetVolumeForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel,
		float newValue
) {
	example->mixer->setChannelVolume(channel, newValue);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetRollEnabledForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel,
		float newValue
) {
	example->mixer->setChannelRollEnabled(channel, newValue);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetRollDisabledForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel
) {
	example->mixer->setChannelRollDisable(channel);
}

extern "C" JNIEXPORT void
Java_com_superpowered_universalpapp_MainActivity_MixerSetPitchShiftForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel,
		int newValue
) {
	example->mixer->setChannelPitchShift(channel, newValue);
}

extern "C" JNIEXPORT int
Java_com_superpowered_universalpapp_MainActivity_MixerGetPitchShiftForChannel(
		JNIEnv *env,
		jobject __unused obj,
		int channel
) {
	return example->mixer->getChannelPitchShift(channel);
}


