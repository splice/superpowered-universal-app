cmake_minimum_required(VERSION 3.4.1)

# convert SDK path to forward slashes on Windows
file(TO_CMAKE_PATH ${PATH_TO_SUPERPOWERED} PATH_TO_SUPERPOWERED)

include_directories(src/main/cpp)
include_directories(${PATH_TO_SUPERPOWERED})
include_directories(${PATH_TO_SUPERPOWERED}/../cpp)

# compile crossfader example to a native library
add_library(
	SuperpoweredUniversalApp
	SHARED
		src/main/cpp/SuperpoweredUniversalApp.cpp
	${PATH_TO_SUPERPOWERED}/OpenSource/SuperpoweredAndroidAudioIO.cpp
	${PATH_TO_SUPERPOWERED}/../cpp/MixerChannel.cpp
	${PATH_TO_SUPERPOWERED}/../cpp/MixerEngine.cpp
)

# link the native library against the following libraries
target_link_libraries(
	SuperpoweredUniversalApp
    log
    OpenSLES
    ${PATH_TO_SUPERPOWERED}/libSuperpoweredAndroid${ANDROID_ABI}.a
)