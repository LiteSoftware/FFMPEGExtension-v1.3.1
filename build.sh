#!/bin/bash

# More details: https://udfsoft.com 

ENABLED_DECODERS=(mp3 vorbis opus flac alac aac ac3 eac3 dca mlp truehd)
HOST_PLATFORM="linux-x86_64"
NDK_PATH="$(pwd)/android-ndk-r26c"
SDK_PATH=$1
ANDROID_ABI=21

# SDK_PATH=/home/user/Android/Sdk

if [ -z $1  ]; then
  echo 'Pass SDK_PATH!'
  echo 'Example: ./build.sh /home/udfsoft/Android/Sdk'
  exit
fi

echo ""
echo "====  Download android-ndk-r26c-linux.zip  ===="
echo ""

wget https://dl.google.com/android/repository/android-ndk-r26c-linux.zip -O ndk.zip
unzip ./ndk.zip

echo ""
echo "====  Clone media ExoPlayer  ===="
echo ""

git clone https://github.com/androidx/media
cd media

EXOPLAYER_PATH="$(pwd)"
FFMPEG_MODULE_PATH="$(pwd)/libraries/decoder_ffmpeg/src/main"

if [ -d ./ffmpeg ]; then
  echo "ffmpeg directory exists!"
  echo "Remove it!"
  rm -R -f ./ffmpeg
fi

echo ""
echo "====  Clone ffmpeg  ===="
echo ""

git clone git://source.ffmpeg.org/ffmpeg
cd ffmpeg
git checkout release/6.0
FFMPEG_PATH="$(pwd)"

cd "${FFMPEG_MODULE_PATH}/jni"

echo "cd to ${FFMPEG_MODULE_PATH}/jni"


rm -R -f ./ffmpeg

ls

ln -s "$FFMPEG_PATH" ffmpeg

cd "${FFMPEG_MODULE_PATH}/jni"

echo ""
echo "====  Build ffmpeg!  ===="
echo ""

./build_ffmpeg.sh "${FFMPEG_MODULE_PATH}" "${NDK_PATH}" "${HOST_PLATFORM}" "${ANDROID_ABI}" "${ENABLED_DECODERS[@]}"


cd $EXOPLAYER_PATH

echo ""
echo "====  Create local.properties file  ===="
echo ""

echo "sdk.dir=${SDK_PATH}" > local.properties

echo ""
echo "====  Build AAR  ===="
echo ""

./gradlew lib-decoder-ffmpeg:assembleRelease

echo ""
echo "The library is complete!"
echo "It should be located in this path: ${EXOPLAYER_PATH}/extensions/ffmpeg/buildout/outputs/aar/"
