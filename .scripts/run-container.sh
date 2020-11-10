#!/bin/bash -exv
#
#
set -exv
#Docker Enable Guid Apps to run
#xhost +

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
	LIBS_DIR="/home/dev/.libs"
	pushd /
	sudo tar xvf "$LIBS_DIR/apache.conf/etc.apache2.tar.xz"
	popd
	sudo usermod -a -G dev www-data
	sudo apachectl start
	#sudo tail -F /var/log/apache2/error.log
}

function configureQtCreator()
{
	SCRIPTS_DIR="/home/dev/.scripts"
	sudo cp $SCRIPTS_DIR/qtcreator.sh /usr/local/bin/qtcreator
	sudo rm -fr /home/dev/.config
	sudo ln -s /home/dev/$DOCKERUSER/.config /home/dev/.config
}

function configureFFMpegScript()
{
	LIBS_DIR="/home/dev/.libs"
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
	export PATH=$PATH:$SCRIPTS_DIR:$LIBS_DIR/ffmpeg
	
	rm $SCRIPTS_DIR/build-image.sh
}
function configureCMake()
{
	LIBS_DIR="/home/dev/.libs"
	CMAKE_VERSION="3.19.0-rc2"
	if [ -d "$LIBS_DIR/cmake-$CMAKE_VERSION/bin" ]; then
		export PATH=$PATH:$LIBS_DIR/cmake-$CMAKE_VERSION/bin
		return;
	fi
}
#####################################################################################
function main()
{
	if [ "$DOCKERUSER" = "" ]; then echo "Environment variable DOCKERUSER was not set during docker run command. $DOCKERUSER"; exit -1; fi

	configureUserDirectory "Downloads"
	configureUserDirectory "Documents"
	installSshKeys
	configureGit
	configureMysql
	configureApache2
	configureQtCreator
	configureCMake
	configureFFMpegScript

# copy built libs back to directory so next time its faster to build docker image:
#sudo rsync -uav ~/.libs ~/$DOCKERUSER/leila.docker/

}

main
bash
