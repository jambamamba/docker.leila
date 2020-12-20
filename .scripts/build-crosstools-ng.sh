#!/bin/bash -ex
set -ex

function main()
{
	if [ ! -d crosstool-ng ]; then
		git clone https://github.com/jambamamba/crosstool-ng.git
	fi
	pushd crosstool-ng

	#sudo apt-get install -y bison cvs flex gperf texinfo automake libtool unzip help2man gawk libtool-bin libtool-doc libncurses5-dev libncursesw5-dev protobuf-compiler kpartx

	if [ ! -f config.h ]; then
		./bootstrap
		./configure --prefix=${PWD}/build
	fi
	make -j$(getconf _NPROCESSORS_ONLN)
	make install

	local PI_TOOLCHAIN_ROOT_DIR=${HOME}/${DOCKERUSER}/pi
	export PI_TOOLCHAIN_ROOT_DIR=${PI_TOOLCHAIN_ROOT_DIR}

	mkdir -p staging
	pushd staging
	unset CC
	unset CXX
	unset LD_LIBRARY_PATH
	ln -s ../raspi0.config .config

	#We already have a .config file, so we do not need to go through the menuconfig steps
	#../build/bin/ct-ng menuconfig  
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
			
	../build/bin/ct-ng build
	popd
	popd
	
	if [ ! -f ${PI_TOOLCHAIN_ROOT_DIR}/Toolchain-RaspberryPi.cmake ]; then
		ln -s ${HOME}/.scripts/Toolchain-RaspberryPi.cmake ${PI_TOOLCHAIN_ROOT_DIR}/Toolchain-RaspberryPi.cmake
	fi
}

main


