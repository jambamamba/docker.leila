#!/bin/bash -xe
set -xe

#####################################################################################
function parseArgs()
{
  for change in $@; do
      set -- `echo $change | tr '=' ' '`
      echo "variable name == $1  and variable value == $2"
      #can assign value to a variable like below
      eval $1=$2;
  done
}

function installPackages()
{
	apt-get update --ignore-missing --fix-missing
#apt-get update
#apt --fix-broken -y install
DEBIAN_FRONTEND=noninteractive apt-get install --ignore-missing  -y \
 apache2\
 apt-utils\
 autoconf\
 automake\
 automake\
 bash-completion\
 bc\
 bison\
 build-essential\
 chromium-browser\
 clang\
 cowsay\
 cpio\
 curl\
 dclock\
 dos2unix\
 emacs\
 firefox\
 fonts-liberation\
 fortune\
 freeglut3-dev\
 gdb\
 gedit\
 genext2fs\
 htop\
 inetutils-ping\
 jq\
 kpartx\
 less\
 libapache2-mod-php7.2\
 libatlas-base-dev\
 libavcodec-dev\
 libavformat-dev\
 libc++-dev\
 libc++abi-dev\
 libcgal-dev\
 libcurl4-openssl-dev\
 libgl1-mesa-dev\
 libglew-dev\
 libglfw3-dev\
 libglu1-mesa-dev\
 libgstreamer-plugins-base1.0-dev\
 libgstreamer1.0-dev\
 libgtk-3-dev\
 libgtk2.0-dev\
 libidn11\
 libjpeg-dev\
 libjpeg-dev\
 libncurses5-dev\
 libonig-dev\
 libopenexr-dev\
 libpng-dev\
 libpng-dev\
 libprotobuf-dev\
 libpulse-mainloop-glib0\
 libsqlite3-dev\
 libssl-dev\
 libsuitesparse-dev\
 libswscale-dev\
 libtiff-dev\
 libtiff-dev\
 libtool\
 libwebp-dev\
 libxcb-icccm4\
 libxcb-image0\
 libxcb-keysyms1\
 libxcb-render-util0\
 libxcb-xinerama0\
 libxi-dev\
 libxkbcommon-x11-0\
 libxml++2.6-dev\
 libxmu-dev\
 libxrandr-dev\
 libxss1\
 libxxf86vm-dev\
 libxxf86vm1\
 libzip-dev\
 mcrypt\
 meld\
 mysql-server\
 nasm\
 ninja-build\
 php-pear\
 php7.2-bcmath\
 php7.2-bz2\
 php7.2-cli\
 php7.2-curl\
 php7.2-dev\
 php7.2-fpm\
 php7.2-gd\
 php7.2-intl\
 php7.2-json\
 php7.2-mbstring\
 php7.2-mysql\
 php7.2-opcache\
 php7.2-sqlite3\
 php7.2-xml\
 php7.2-zip\
 php7.2\
 pkg-config\
 python3-dev\
 python3-h5py\
 python3-numpy\
 python3-scipy\
 python3.pip\
 python3-yaml\
 python3\
 re2c\
 rpm2cpio\
 rsync\
 software-properties-common\
 sqlite3\
 sshfs\
 subversion\
 thunar\
 ufw\
 vim\
 wget\
 yasm\

 python3 -m pip install --upgrade pip
 pip3 install setuptools tensorflow opencv-python scikit-image imgaug pycocotools matplotlib numpy keras_preprocessing
}

function makeUserDirectories()
{
	mkdir -p /home/dev
	mkdir -p /home/dev/Downloads
	mkdir -p /home/dev/Documents
}

function createUser()
{
	apt-get install -y sudo
	groupadd --gid 1000 dev
	useradd --system --create-home --home-dir /home/dev --shell /bin/bash --gid root --groups sudo,dev --uid 1000 dev
	passwd -d dev
	export uid=1000 gid=1000
	chown -R dev:dev /home/dev
	echo "root:root" | chpasswd
	echo "dev:dev" | chpasswd
	export "PS1=$(whoami)@$(hostname):$(pwd) >
cd /home/dev/\
"
}
function configureLibsDirectory()
{	
	LIBS_DIR="/home/dev/.libs"
	sudo mkdir -p $LIBS_DIR
	sudo chown -R dev:dev $LIBS_DIR
	#mv -f /tmp/.libs /home/dev
	sudo chown -R dev:dev /home/dev/.libs
}
function configureScriptsDirectory()
{
	sudo mv -f /tmp/.scripts /home/dev
	sudo chown -R dev:dev /home/dev/.scripts
}
function configureSelfSignedCertificate()
{
	mv -f /tmp/.certs /home/dev
	sudo chown -R dev:dev /home/dev/.certs
	pushd /home/dev/.certs/
	sudo mkdir -p /home/dev/.ssh/
	if [[ ! -f "self-signed.crt" || ! -f "self-signed.key" ]]; then
		openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout server.key -out server.crt -subj '/O=Company/OU=Department/CN=osletek.com'
		sudo cp server.crt /home/dev/.ssh/self-signed.crt
		sudo cp server.key /home/dev/.ssh/self-signed.key
	else
		sudo cp self-signed.crt /home/dev/.ssh/self-signed.crt
		sudo cp self-signed.key /home/dev/.ssh/self-signed.key
	fi
	popd
}
function configureOpenGl()
{
	LIBS_DIR="/home/dev/.libs"
	pushd /
	sudo mv -f $LIBS_DIR/gl/* /usr/lib/x86_64-linux-gnu/
	popd
}
function installGoogleChromeBrowser()
{
	pushd /tmp
	if [ ! -f "/tmp/google-chrome-stable_current_amd64.deb" ]; then 
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	fi

	sudo apt --fix-broken install
	sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
	sudo rm -f /tmp/google-chrome-stable_current_amd64.deb
	popd
}

function installLibraryFromCache()
{
	parseArgs $@
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/$LIBRARY" ]; then
		pushd $LIBS_DIR/$LIBRARY
		make install
		popd
		RESULT=1
	fi
	return
}

function installXiphLibrary()
{
	LIBS_DIR="/home/dev/.libs"
	RES=0
	installLibraryFromCache LIBRARY=$1 RESULT=$RES
	RES=$RESULT
	if [ $RES -eq 1 ]; then return; fi

	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://github.com/xiph/$1.git
	pushd $1
	./autogen.sh
	./configure --enable-shared
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installMp3Lame()
{
	LIBS_DIR="/home/dev/.libs"
	RES=0
	installLibraryFromCache LIBRARY=mp3lame RESULT=$RES
	RES=$RESULT
	if [ $RES -eq 1 ]; then return; fi

	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	svn checkout https://svn.code.sf.net/p/lame/svn/trunk/lame mp3lame
	pushd mp3lame
	./configure --enable-shared --enable-nasm
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installVpx()
{
	LIBS_DIR="/home/dev/.libs"
	RES=0
	installLibraryFromCache LIBRARY=libvpx RESULT=$RES
	RES=$RESULT
	if [ $RES -eq 1 ]; then return; fi

	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://chromium.googlesource.com/webm/libvpx
	pushd libvpx
	CFLAGS="-fPIC" ./configure --enable-vp8 --enable-vp9 --enable-webm-io --enable-shared
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installX264()
{
	LIBS_DIR="/home/dev/.libs"
	RES=0
	installLibraryFromCache LIBRARY=x264 RESULT=$RES
	RES=$RESULT
	if [ $RES -eq 1 ]; then return; fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://code.videolan.org/videolan/x264.git
	pushd x264
	./configure --enable-shared --disable-asm
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installFFMpegDependencies()
{
	installMp3Lame
	installXiphLibrary ogg
	installXiphLibrary vorbis
	installXiphLibrary theora
	installVpx
	installX264
}

function installFFMpeg()
{
	installFFMpegDependencies
	
	LIBS_DIR="/home/dev/.libs"
	RES=0
	installLibraryFromCache LIBRARY=ffmpeg RESULT=$RES
	RES=$RESULT
	if [ $RES -eq 1 ]; then return; fi

	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
	pushd ffmpeg
	./configure --enable-shared --arch=x86 --enable-libvpx --enable-libtheora --disable-encoder=vorbis --enable-libvorbis --enable-libmp3lame --enable-libx264 --enable-gpl
	make -j$(getconf _NPROCESSORS_ONLN)
	popd
	popd
}

function installOpenCV()
{
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/opencv/build" ]; then
		return;
	fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	if [ ! -d "$LIBS_DIR/opencv" ]; then
		git clone  https://github.com/opencv/opencv.git
	fi
	pushd opencv
	mkdir -p build
	pushd build
	cmake ../
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installAlsa()
{
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/alsa-lib" ]; then
		return;
	fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://github.com/alsa-project/alsa-lib.git
	pushd alsa-lib
	libtoolize
	aclocal
	automake --add-missing --force-missing --copy --foreign && true
	autoreconf
	./configure 
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installGifLib()
{
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/giflib" ]; then
		return;
	fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://github.com/mldbai/giflib.git
	pushd giflib
	./configure 
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
	popd
}

function installKeras()
{
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/keras" ]; then
		pushd "$LIBS_DIR/keras"
		pip3 install keras
		popd
		return 0;
	fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	git clone https://github.com/keras-team/keras.git
	pushd keras
	pip3 install keras
	popd

	pip list | grep tensorflow
	pip3 show keras
}

function installCMake()
{
	LIBS_DIR="/home/dev/.libs"
	CMAKE_VERSION="3.19.0-rc2"
	
	if [ -d "$LIBS_DIR/cmake-$CMAKE_VERSION/bin" ];then
		export PATH=$PATH:$LIBS_DIR/cmake-$CMAKE_VERSION/bin
		return 0;
	fi
	
	mkdir -p $LIBS_DIR
	pushd "$LIBS_DIR"
	wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
	tar -xzvf cmake-$CMAKE_VERSION.tar.gz
	pushd cmake-$CMAKE_VERSION
	./configure --parallel=$(getconf _NPROCESSORS_ONLN)
	make -j$(getconf _NPROCESSORS_ONLN)
	popd
	popd

	export PATH=$PATH:$LIBS_DIR/cmake-$CMAKE_VERSION/bin
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
	LIBS_DIR="/home/dev/.libs"
	if [ -d "$LIBS_DIR/tensorflow" ]; then
		pushd "$LIBS_DIR/tensorflow"
		return 0;
	fi
	
	mkdir -p $LIBS_DIR
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

function setLibsOwnership()
{
	sudo chown -R dev:dev /home/dev/.libs
}
function main()
{
	installPackages
	makeUserDirectories
	createUser
	configureLibsDirectory
	configureScriptsDirectory
	configureSelfSignedCertificate
	configureOpenGl
	installGoogleChromeBrowser
	installCMake
	installAlsa
	installGifLib
	installFFMpeg
	installOpenCV
	#installBazel
	#installTensorflow
	installKeras
	setLibsOwnership
}

main
