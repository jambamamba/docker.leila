#!/bin/bash -e
set -e

function main()
{
	local PI_ROOT="pi"
	
	if [ -d ${HOME}/${DOCKERUSER}/${PI_ROOT} ]; then 
		echo "${HOME}/${DOCKERUSER}/${PI_ROOT} already exists. Exiting..."
		exit(0)
	fi
	
	mkdir -p  ${HOME}/${DOCKERUSER}/${PI_ROOT}/src/
	pushd ${HOME}/${DOCKERUSER}/${PI_ROOT}/src/
	
	local VERSION="1.24.0"
	if [ ! -d crosstool-ng-$VERSION ]; then
		if [ ! -f crosstool-ng-$VERSION.tar.bz2 ]; then
			wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$VERSION.tar.bz2
		fi
		tar xjf crosstool-ng-$VERSION.tar.bz2
		rm -f crosstool-ng-$VERSION.tar.bz2
	fi
	pushd crosstool-ng-$VERSION

	#sudo apt-get install -y bison cvs flex gperf texinfo automake libtool unzip help2man gawk libtool-bin libtool-doc libncurses5-dev libncursesw5-dev protobuf-compiler kpartx

	if [ ! -f config.h ]; then
		./configure --prefix=${HOME}/${DOCKERUSER}/${PI_ROOT}/crosstool-ng
	fi
	make -j8
	#make install

	export PATH=$PATH:${HOME}/${DOCKERUSER}/${PI_ROOT}/crosstool-ng/bin
	export PI_ROOT=${PI_ROOT}

	mkdir -p ${HOME}/${DOCKERUSER}/${PI_ROOT}/src/staging
	pushd ${HOME}/${DOCKERUSER}/${PI_ROOT}/src/staging
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
	#					> Floating point : hardward FPU
	#					> Emit assembly for CPU (none)
	#		> tune for cpu (nothing, no ev4)
	#
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
	ct-ng build
	popd
	popd
	popd
}

main


