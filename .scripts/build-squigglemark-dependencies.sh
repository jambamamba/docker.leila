#!/bin/bash -xe
set -xe

source $(dirname `realpath $0`)/utils.sh

function installZLib()
{
	libExists LIB="libz.so" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	local LIB="zlib-1.2.11"
	local EXT="tar.gz"
	local URL="https://www.zlib.net/${LIB}.${EXT}"
	procureLib LIB=${LIB} EXT=${EXT} URL=${URL}
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
}

function installPngLib()
{
	libExists LIB="png" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	local LIB="libpng-1.6.37"
	local EXT="tar.xz"
	local URL="https://download.sourceforge.net/libpng/${LIB}.${EXT}"
	procureLib LIB=${LIB} EXT=${EXT} URL=${URL}
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
}

function prepareJpegSources()
{
	parseArgs $@

	pushd $LIBS_DIR/${LIB}
	sed -i -e 's/\r//g' configure #remove ^M character
	sed -i -e 's/\r//g' config.sub #remove ^M character
	sed -i -e 's/\r//g' config.guess #remove ^M character
	chmod +x configure
	autoreconf -if
	popd
}

function installJpegLib()
{
	libExists LIB="jpeg" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	local LIB="jpegsr9c"
	local EXT="zip"
	local URL="http://www.ijg.org/files/${LIB}.${EXT}"
	procureLib LIB=${LIB} EXT=${EXT} URL=${URL}
	prepareJpegSources LIB=${LIB} EXT=${EXT} URL=${URL}
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"

	find $LIBS_DIR/${LIB}/ -name "*.h" | xargs sudo cp -Pt /usr/local/include/
}

function installFreetypeLib()
{
	libExists LIB="freetype" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	local LIB="freetype-2.10.0"
	local EXT="tar.gz"
	local URL="https://download.savannah.gnu.org/releases/freetype/${LIB}.${EXT}"
	procureLib LIB=${LIB} EXT=${EXT} URL=${URL}
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
}

function installXiphLibrary()
{
	parseArgs $@

	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/xiph/${LIB}.git" LIB=$LIB
	pushd $LIBS_DIR/${LIB}
	./autogen.sh
	popd
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
	pushd $LIBS_DIR/${LIB}
	sudo make install
	popd
}

function installMp3Lame()
{
	local LIB="mp3lame"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="svn" SCM_CMD="checkout" URL="https://svn.code.sf.net/p/lame/svn/trunk/lame" LIB=$LIB
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared#--enable-nasm"
}

function installVpx()
{
	local LIB="vpx"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://chromium.googlesource.com/webm/lib$LIB" LIB=$LIB
	makeLib LIB=${LIB} CFLAGS="-fPIC" CONF_FLAGS="--enable-shared#--enable-vp8#--enable-vp9#--enable-webm-io"
}

function installX264()
{
	local LIB="x264"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://code.videolan.org/videolan/$LIB.git" LIB=$LIB
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared#--disable-asm"
}

function installFFMpegDependencies()
{
	installMp3Lame
	installXiphLibrary LIB=ogg
	installXiphLibrary LIB=vorbis
	installXiphLibrary LIB=theora
	installVpx
	installX264
}

function copyFFMpegBinaries()
{
	cp "$LIBS_DIR/ffmpeg/ffmpeg" $DOCKER_BIN/
	cp "$LIBS_DIR/ffmpeg/ffplay" $DOCKER_BIN/
}

function installFFMpeg()
{
	installFFMpegDependencies

	libExists LIB="avcodec" RESULT=0
	if [ $RESULT -gt 0 ]; then
		copyFFMpegBinaries
		return 0; 
	fi

	local LIB="ffmpeg"
	procureLib SCM="git" SCM_CMD="clone" URL="https://git.ffmpeg.org/$LIB.git" LIB=$LIB
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared#--arch=x86#--enable-libvpx#--enable-libtheora#--disable-encoder=vorbis#--enable-libvorbis#--enable-libmp3lame#--enable-libx264#--enable-gpl#--enable-ffplay"
	
	copyFFMpegBinaries
}

function installOpenCV()
{
	local LIB="opencv"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/opencv/$LIB.git" LIB=$LIB
	makeLib LIB=${LIB} BUILDSYSTEM="cmake"
}

function installAlsa()
{
	libExists LIB="sound" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	local LIB="alsa"
	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/alsa-project/$LIB-lib.git" LIB=$LIB
	pushd $LIBS_DIR/${LIB}
	libtoolize
	aclocal
	automake --add-missing --force-missing --copy --foreign && true
	autoreconf
	popd
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
}

function installGifLib()
{
	local LIB="gif"
	libExists LIB="$LIB" RESULT=0
	if [ $RESULT -gt 0 ]; then return 0; fi

	procureLib SCM="git" SCM_CMD="clone" URL="https://github.com/mldbai/giflib.git" LIB=$LIB
	makeLib LIB=${LIB} CONF_FLAGS="--enable-shared"
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

function installBazel()
{
	sudo apt install curl gnupg
	curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
	sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

	sudo apt update && sudo apt install -y bazel
	sudo apt update && sudo apt full-upgrade
}

function installTensorflow()
{
	if [ -d "$LIBS_DIR/tensorflow" ]; then
		pushd "$LIBS_DIR/tensorflow"
		return 0;
	fi

	pushd $LIBS_DIR
	git clone https://github.com/tensorflow/tensorflow.git
	pushd tensorflow
	git checkout r1.4
	yes "" | ./configure -y cuda=Y -march=native --config=mkl --config=v1
	#/usr/local/cuda-10.1/targets/x86_64-linux/lib/
	bazel build --config=v1 //tensorflow/tools/pip_package:build_pip_package
	bazel build --config=cuda --config=v1 //tensorflow/tools/pip_package:build_pip_package
	bazel build //tensorflow/tools/pip_package:build_pip_package
	#./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
	popd

	pip list | grep tensorflow
	pip3 show keras

}

function installAllLibs()
{
	sudo chown -R dev:dev $DOCKER_LIB
	sudo chown -R dev:dev $DOCKER_BIN
	sudo chown -R dev:dev $BUILD_DIR
	cp -P $BUILD_DIR/* $DOCKER_LIB/

	echo "/home/dev/lib" > /tmp/leila.conf
	sudo mv /tmp/leila.conf /etc/ld.so.conf.d/leila.conf
	sudo ldconfig

	sudo cp -r /tmp/.leila /home/dev/$DOCKERUSER/
}

function main()
{
	configureLibsDirectory
	installZLib
	installPngLib
	installJpegLib
	installFreetypeLib
	installAlsa
	installGifLib
	installFFMpeg
	installOpenCV
	#installBazel
	#installTensorflow
	installKeras
	installAllLibs
}

main
