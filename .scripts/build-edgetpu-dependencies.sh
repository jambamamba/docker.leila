#!/bin/bash -xe
set -xe

source $(dirname `realpath $0`)/utils.sh

function buildLibUsb()
{
	local LIB="libusb"
	local CMAKE_BUILD_DIR="buildpi"
	if [ -f "$LIBS_DIR/${LIB}/${CMAKE_BUILD_DIR}/libusb.so" ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/libusb/libusb.git" LIB=$LIB
	pushd $LIBS_DIR/${LIB}
	./autogen.sh
	cp ~/.scripts/libusb/CMakeLists.txt .
	popd
	makeLib LIB=${LIB} BUILDSYSTEM="cmake" CMAKE_BUILD_DIR="$CMAKE_BUILD_DIR" CMAKE_TOOLCHAIN_FILE="$HOME/$DOCKERUSER/pi/Toolchain-RaspberryPi.cmake"
	rm -f $BUILD_DIR/libusb.so #makeLib copies file to BUILD_DIR, but this is rpi arch, so don't need it there	
	pushd $LIBS_DIR/${LIB}/${CMAKE_BUILD_DIR}
	ln -s libusb.so libusb-1.0.so
	ln -s libusb-1.0.so libusb-1.0.so.0
	popd
}

## delete it
function buildAbseilCpp()
{
	local LIB="abseil-cpp"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/abseil/abseil-cpp.git" LIB=$LIB
	makeLib LIB=${LIB} BUILDSYSTEM="cmake" CMAKE_BUILD_DIR="buildpi" CMAKE_TOOLCHAIN_FILE="$HOME/$DOCKERUSER/pi/Toolchain-RaspberryPi.cmake"
}

## delete it
function installEigen()
{
	local LIB="eigen3"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/OPM/eigen3.git" LIB=$LIB
}

## delete it
function installGoogleTest()
{
	local LIB="googletest"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/google/googletest.git" LIB=$LIB
}

function installSystemD()
{
	local LIB="systemd"
	if [ -f "$LIBS_DIR/${LIB}" ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/systemd/systemd.git" LIB=$LIB
}

function installKeras()
{
	if [ -d "$LIBS_DIR/keras" ]; then
		pushd "$LIBS_DIR/keras"
		pip3 install keras
		popd
		return 0;
	fi

	pushd $LIBS_DIR
	git clone https://github.com/keras-team/keras.git
	pushd keras
	pip3 install keras
	popd

	pip list | grep tensorflow
	pip3 show keras
}

## delete it
function installFlatBuffers()
{
	sudo apt-add-repository -y ppa:hnakamur/flatbuffers
	sudo apt update
	sudo apt install -y flatbuffers-compiler

	local LIB="flatbuffers"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/google/flatbuffers.git" LIB=$LIB
}

function buildTensorflow()
{
	local LIB="tensorflow"
	local TF_MAKE_DIR="tensorflow/lite/tools/make"
	if [ -f "$LIBS_DIR/${LIB}/$TF_MAKE_DIR/gen/rpi_armv7l/lib/libtensorflow-lite.a" ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/tensorflow/tensorflow.git" LIB=$LIB
	pushd $LIBS_DIR/${LIB}
	rm -fr $TF_MAKE_DIR/downloads
	./$TF_MAKE_DIR/download_dependencies.sh
	PATH=$HOME/$DOCKERUSER/pi/x-tools/arm-rpi-linux-gnueabihf/bin:$PATH ./$TF_MAKE_DIR/build_rpi_lib.sh
	popd
}

function buildEdgeTpu()
{
	local LIB="libedgetpu"
	if [ -f "$LIBS_DIR/${LIB}/out/direct/rpi/${LIB}.so.1.0" ] && [ -f "$LIBS_DIR/${LIB}/out/throttled/rpi/${LIB}.so.1.0" ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/jambamamba/libedgetpu.git" LIB=$LIB
	pushd $LIBS_DIR/${LIB}
	make
	popd
}

function main()
{
	configureLibsDirectory
	##installPiToolchain #todo
	buildTensorflow
	installSystemD
	buildLibUsb
	#installEigen
	#installFlatBuffers
	#buildAbseilCpp
	#installGoogleTest
	buildEdgeTpu
	#installKeras
}

main
