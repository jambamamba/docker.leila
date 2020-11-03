#!/bin/bash -xe
set -xe

#####################################################################################

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
 pip3 install setuptools
 pip3 install tensorflow
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

function main()
{
	installPackages
	makeUserDirectories
	createUser
}

main
