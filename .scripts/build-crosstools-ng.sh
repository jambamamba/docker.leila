#!/bin/bash -ex
set -ex

function main()
{
	local PI_TOOLCHAIN_ROOT_DIR=${HOME}/${DOCKERUSER}/pi2
	
	if [ -d ${PI_TOOLCHAIN_ROOT_DIR} ]; then 
		echo "${PI_TOOLCHAIN_ROOT_DIR} already exists. Exiting..."
		exit 0
	fi
	
	mkdir -p  ${PI_TOOLCHAIN_ROOT_DIR}/src/
	pushd ${PI_TOOLCHAIN_ROOT_DIR}/src/
	
	local VERSION="1.24.0"
	if [ ! -d crosstool-ng-$VERSION ]; then
		mkdir -p ${HOME}/${DOCKERUSER}/Downloads
		pushd ${HOME}/${DOCKERUSER}/Downloads
		if [ ! -f crosstool-ng-$VERSION.tar.bz2 ]; then
			wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$VERSION.tar.bz2
		fi
		popd
		ln -s ${HOME}/${DOCKERUSER}/Downloads/crosstool-ng-$VERSION.tar.bz2 crosstool-ng-$VERSION.tar.bz2
		tar xjf crosstool-ng-$VERSION.tar.bz2
	fi
	pushd crosstool-ng-$VERSION

	#sudo apt-get install -y bison cvs flex gperf texinfo automake libtool unzip help2man gawk libtool-bin libtool-doc libncurses5-dev libncursesw5-dev protobuf-compiler kpartx

	if [ ! -f config.h ]; then
		./configure --prefix=${PI_TOOLCHAIN_ROOT_DIR}/crosstool-ng
	fi
	make -j8
	make install

	export PATH=$PATH:${PI_TOOLCHAIN_ROOT_DIR}/crosstool-ng/bin
	export PI_TOOLCHAIN_ROOT_DIR=${PI_TOOLCHAIN_ROOT_DIR}

	mkdir -p ${PI_TOOLCHAIN_ROOT_DIR}/src/staging
	pushd ${PI_TOOLCHAIN_ROOT_DIR}/src/staging
	unset CC
	unset CXX
	unset LD_LIBRARY_PATH

	#We already have a .config file, so we do not need to go through the menuconfig steps
	#ct-ng  menuconfig   
	#The menuconfig presents a UI that lets you create the .config file.
	#In the UI, follow these steps:
	#Paths and misc options > Prefix directory >  /home/oosman/pi2/x-tools/${CT_TARGET}  
	#			> Number of parallel jobs 8 
	#Target options > Target Architecture 	> arm
	#					> Suffix to the arch-part > rpi
	#					> Floating point : hardward FPU
	#					> Emit assembly for CPU (none)
	#					> tune for cpu (nothing, no ev4)
	#Operating System > Target OS > linux
	#Binary utilities > Linkers to enable > ld,gold
	#					> Enable threaded gold
	#C-library > Version of glibc (2.29)
	#	  > Create /etc/ld.so.conf file
	#C compiler > C++
	#Companion tools > autoconf
	#			> automake
	#			> libtool
	#			> make
	#Exit
	#Save
			
	cp -f ${HOME}/.scripts/crosstool-ng.raspi0.config .config
	${PI_TOOLCHAIN_ROOT_DIR}/crosstool-ng/bin/ct-ng build
	popd
	popd
	popd
	
	if [ ! -f ${PI_TOOLCHAIN_ROOT_DIR}/Toolchain-RaspberryPi.cmake ]; then
		ln -s ${HOME}/.scripts/Toolchain-RaspberryPi.cmake ${PI_TOOLCHAIN_ROOT_DIR}/Toolchain-RaspberryPi.cmake
	fi
}

main


