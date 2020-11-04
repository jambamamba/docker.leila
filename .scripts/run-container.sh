#!/bin/bash -exv
#
#
set -exv

function installSshKeys()
{
	echo "installSshKeys"
	if [ -d "/home/dev/.ssh" ]; then 
		echo "/home/dev/.ssh exists"
	else
		echo "setting link to .ssh"
		ln -s /home/dev/$DOCKERUSER/.ssh /home/dev/
	fi
}


function configureGit()
{
    echo "configureGit"
	if [ "$GITUSER" = "" ]; then echo "Environment variable GITUSER was not set during docker run command. $GITUSER"; exit -1; else
	   echo "setting git user as $GITUSER"
	   git config --global user.name "$GITUSER"
	fi
	if [ "$GITEMAIL" = "" ]; then echo "Environment variable GITUSER was not set during docker run command. $GITUSER"; exit -1; else
	   echo "setting git email as $GITEMAIL"
	   git config --global user.email "$GITEMAIL"
	fi
}

function configureUserDirectory()
{
    echo "configure" $1
    mkdir -p /home/dev/$DOCKERUSER/$1/
    sudo cp -nr /home/dev/$1/* /home/dev/$DOCKERUSER/$1/ && true
    rm -fr /home/dev/$1 
    ln -s /home/dev/$DOCKERUSER/$1 /home/dev/$1 && true
}

function configureScriptsDirectory()
{
	sudo mv /tmp/.scripts /home/dev
	sudo chown -R dev:dev /home/dev/.scripts
}

function configureSelfSignedCertificate()
{
	sudo cp -r /tmp/.certs /home/dev
	pushd /home/dev/.certs/
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

function configureMysql()
{
	if [ -d "/home/dev/$DOCKERUSER/mysqldb" ]; then
		sudo cp -r /home/dev/$DOCKERUSER/mysqldb /var/lib/mysql/oosman
		sudo /etc/init.d/mysql start
		return
	fi
	
	sudo /etc/init.d/mysql start
	echo "CREATE USER 'dev'@'localhost' IDENTIFIED BY 'a';
	GRANT ALL PRIVILEGES ON *.* TO 'dev'@'localhost' IDENTIFIED BY 'a';
	FLUSH PRIVILEGES;
	CREATE DATABASE oosman;
	" > configdb.sql
	sudo mysql -u root < configdb.sql
	if [ -f "/home/dev/$DOCKERUSER/work.web.git/he.sql" ]; then
		sudo mysql -u dev --password=a oosman < /home/dev/$DOCKERUSER/work.web.git/he.sql 
	fi
}

function configureApache2()
{
	pushd /
	sudo tar xvf "/tmp/.libs/apache.conf/etc.apache2.tar.xz"
	popd
	sudo usermod -a -G dev www-data
	sudo apachectl start
	#sudo tail -F /var/log/apache2/error.log
}

function configureOpenGl()
{
	pushd /
	sudo cp /tmp/.libs/gl/* /usr/lib/x86_64-linux-gnu/
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

function configureQtCreator()
{
	SCRIPTS_DIR="/home/dev/.scripts"
	sudo ln -s $SCRIPTS_DIR/qtcreator.sh /usr/local/bin/qtcreator
	sudo rm -fr /home/dev/.config
	sudo ln -s /home/dev/$DOCKERUSER/.config /home/dev/.config
}

function installXiphLibrary()
{
	git clone https://github.com/xiph/$1.git
	pushd $1
	./autogen.sh
	./configure --enable-shared
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
}

function installMp3Lame()
{
	svn checkout https://svn.code.sf.net/p/lame/svn/trunk/lame lame-svn
	pushd lame-svn
	./configure --enable-shared --enable-nasm
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
}

function installVpx()
{
	git clone https://chromium.googlesource.com/webm/libvpx
	pushd libvpx
	CFLAGS="-fPIC" ./configure --enable-vp8 --enable-vp9 --enable-webm-io --enable-shared
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
	popd
}

function installX264()
{
	git clone https://code.videolan.org/videolan/x264.git
	pushd x264
	./configure --enable-shared --disable-asm
	make -j$(getconf _NPROCESSORS_ONLN)
	make install
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

function configureFFMpegScript()
{
	LIBS_DIR="/home/dev/$DOCKERUSER/.libs"
	echo "$LIBS_DIR/ffmpeg
$LIBS_DIR/ffmpeg/libavdevice
$LIBS_DIR/ffmpeg/libavfilter
$LIBS_DIR/ffmpeg/libavformat
$LIBS_DIR/ffmpeg/libavcodec
$LIBS_DIR/ffmpeg/libpostproc
$LIBS_DIR/ffmpeg/libswresample
$LIBS_DIR/ffmpeg/libswscale
$LIBS_DIR/ffmpeg/libavutil
$LIBS_DIR/libvpx
$LIBS_DIR/x264
" > /tmp/ffmpeg.conf
	sudo mv /tmp/ffmpeg.conf /etc/ld.so.conf.d/ffmpeg.conf
	sudo ldconfig

	SCRIPTS_DIR="/home/dev/.scripts"
	pushd /
	sudo cp $SCRIPTS_DIR/ff.sh $LIBS_DIR/ffmpeg/
	popd

	export PATH=$PATH:$LIBS_DIR/ffmpeg
}

function installFFMpeg()
{
	LIBS_DIR="/home/dev/$DOCKERUSER/.libs"
	if [ -d "$LIBS_DIR/ffmpeg" ]; then
		configureFFMpegScript
		return;
	fi
	
	mkdir -p $LIBS_DIR
	pushd $LIBS_DIR
	
	installFFMpegDependencies
	
	git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
	pushd ffmpeg
	./configure --enable-shared --arch=x86 --enable-libvpx --enable-libtheora --disable-encoder=vorbis --enable-libvorbis --enable-libmp3lame --enable-libx264 --enable-gpl
	make -j$(getconf _NPROCESSORS_ONLN)
	popd

	popd

	configureFFMpegScript
}

function installOpenCV()
{
	LIBS_DIR="/home/dev/$DOCKERUSER/.libs"
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
}

function installKeras()
{
	LIBS_DIR="/home/dev/$DOCKERUSER/.libs"
	if [ -d "$LIBS_DIR/keras" ]; then
		pushd "$LIBS_DIR/keras"
		pip3 install keras
		popd
		return;
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

function configureCMake()
{
	DOWNLOADS_DIR="/home/dev/$DOCKERUSER/Downloads"
	CMAKE_VERSION="3.19.0-rc2"
	if [ -d "$DOWNLOADS_DIR/cmake-$CMAKE_VERSION" ]; then
		export PATH=$PATH:$DOWNLOADS_DIR/cmake-$CMAKE_VERSION/bin
		return;
	fi
	pushd "$DOWNLOADS_DIR"
	wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
	tar -xzvf cmake-$CMAKE_VERSION.tar.gz
	popd

	export PATH=$PATH:$DOWNLOADS_DIR/cmake-$CMAKE_VERSION/bin
}

#####################################################################################
function main()
{
	if [ "$DOCKERUSER" = "" ]; then echo "Environment variable DOCKERUSER was not set during docker run command. $DOCKERUSER"; exit -1; fi

	configureUserDirectory "Downloads"
	configureUserDirectory "Documents"
	configureScriptsDirectory
	installSshKeys
	configureGit
	configureSelfSignedCertificate
	configureMysql
	configureApache2
	configureQtCreator
	configureOpenGl
	configureCMake
	installFFMpeg
	installOpenCV
	installKeras
}

main
bash
