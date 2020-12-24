#!/bin/bash -xe
set -xe

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
 automake\
 bash-completion\
 bc\
 bison\
 bison\
 bluefish\
 build-essential\
 chromium-browser\
 chrpath\
 clang\
 cowsay\
 cpio\
 curl\
 cvs\
 dclock\
 dos2unix\
 emacs\
 firefox\
 flex\
 fonts-liberation\
 fortune\
 freeglut3-dev\
 gawk\
 gdb\
 gedit\
 genext2fs\
 gnupg\
 gperf\
 help2man\
 htop\
 imagemagick-6.q16\
 inetutils-ping\
 intltool\
 jq\
 kpartx\
 kpartx\
 less\
 libapache2-mod-php7.2\
 libatlas-base-dev\
 libavcodec-dev\
 libavformat-dev\
 libc++abi-dev\
 libc++-dev\
 libcgal-dev\
 libcurl4-openssl-dev\
 libgd-dev\
 libgl1-mesa-dev\
 libglew-dev\
 libglfw3-dev\
 libglu1-mesa-dev\
 libgstreamer1.0-dev\
 libgstreamer-plugins-base1.0-dev\
 libgtk2.0-dev\
 libgtk-3-dev\
 libidn11\
 libjpeg-dev\
 libjpeg-dev\
 libmount-dev\
 libncurses5-dev\
 libncurses5-dev\
 libncursesw5-dev\
 libonig-dev\
 libopenexr-dev\
 libpng-dev\
 libpng-dev\
 libprotobuf-dev\
 libpulse-mainloop-glib0\
 libqt5x11extras5-dev\
 libsdl2-dev\
 libsqlite3-dev\
 libssl-dev\
 libsuitesparse-dev\
 libswscale-dev\
 libtiff-dev\
 libtiff-dev\
 libtool\
 libtool\
 libtool-bin\
 libtool-doc\
 libusb-dev\
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
 libxxf86vm1\
 libxxf86vm-dev\
 libzip-dev\
 mcrypt\
 meld\
 mysql-server\
 nasm\
 ninja-build\
 php7.2\
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
 php-pear\
 pkg-config\
 protobuf-compiler\
 python3\
 python3-dev\
 python3-h5py\
 python3-numpy\
 python3.pip\
 python3-scipy\
 python3-yaml\
 re2c\
 rpm2cpio\
 rsync\
 software-properties-common\
 sqlite3\
 sshfs\
 subversion\
 texinfo\
 thunar\
 tig\
 ufw\
 unzip\
 vim\
 wget\
 yasm\

# crossbuild-essential-armhf\
# crossbuild-essential-arm64\
# libpython3-dev:armhf\
# libpython3-dev:arm64\
# libusb-1.0-0-dev:armhf\
# libusb-1.0-0-dev:arm64\

# dpkg --add-architecture armhf
# dpkg --add-architecture arm64

  curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
  mv bazel.gpg /etc/apt/trusted.gpg.d/
  echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
  apt update
  apt install -y bazel graphviz xdot

  python3 -m pip install --upgrade pip
  pip3 install setuptools tensorflow opencv-python scikit-image imgaug pycocotools matplotlib numpy keras_preprocessing meson
}

installPackages
