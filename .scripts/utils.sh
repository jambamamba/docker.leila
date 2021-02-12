#!/bin/bash -xe
set -xe

LIBS_DIR=""		#sources for libraries to be compiled
CACHE_DIR=""	#downloaded packages are kept here so we don't have to download them again
BUILD_DIR=""	#output so files are copied here
DOCKER_BIN=""	# final destination where all executables are copied to and become part of docker image
DOCKER_LIB=""	# final destination where all so files are copied to and become part of docker image

#####################################################################################
function parseArgs()
{
  for change in $@; do
      set -- `echo $change | tr '=' ' '`
      #echo "variable name==$1  and variable value==$2"
      #can assign value to a variable like below
      eval $1=$2
  done
}

function configureLibsDirectory()
{
	if [ "$DOCKERUSER" == "" ]; then
		local HOME_DIR="/tmp"
	else
		local HOME_DIR="/home/dev/$DOCKERUSER"
	fi
	
	if [ -d "$HOME_DIR/.leila" ]; then
		sudo chown -R dev:dev "$HOME_DIR/.leila"
	fi
	
	LIBS_DIR="$HOME_DIR/.leila/lib"
	mkdir -p $LIBS_DIR
	sudo chown -R dev:dev $LIBS_DIR

	CACHE_DIR="$HOME_DIR/.leila/cache"
	mkdir -p $CACHE_DIR
	sudo chown -R dev:dev $CACHE_DIR

	BUILD_DIR="$HOME_DIR/.leila/build"
	mkdir -p $BUILD_DIR
	sudo chown -R dev:dev $BUILD_DIR

	DOCKER_BIN="/home/dev/bin"
	mkdir -p $DOCKER_BIN
	export PATH=$PATH:$DOCKER_BIN/

	DOCKER_LIB="/home/dev/lib"
	mkdir -p $DOCKER_LIB
}

function procureLib()
{
    parseArgs $@

    pushd $LIBS_DIR

	if [ "$SCM" != "" ]; then
		if [ ! -d $LIB ]; then
			$SCM $SCM_CMD $URL $LIB
		fi
	else
		pushd $CACHE_DIR
		if [ ! -f ${LIB}.${EXT} ]; then
			wget ${URL}
		fi
		popd

		rm -fr ${LIB}
		local TAR=""
		if [ "${EXT}" == "tar.gz" ]; then
			tar -xzvf $CACHE_DIR/${LIB}.${EXT}
		elif [ "${EXT}" == "tar.xz" ]; then
			tar xf $CACHE_DIR/${LIB}.${EXT}
		elif [ "${EXT}" == "zip" ]; then
			unzip $CACHE_DIR/${LIB}.${EXT} -d $CACHE_DIR/~${LIB}
			mv $CACHE_DIR/~${LIB}/* ${LIB}
			rm -fr $CACHE_DIR/~${LIB}
		else
			echo "Cannot determine compression format"
			exit -1
		fi
	fi
    popd
}

function libExists()
{
	parseArgs $@

	RESULT=$(ls -lah $BUILD_DIR | grep ${LIB} | wc -l)
}

function makeLib()
{
	local CMAKE_BUILD_DIR="build"
	local CMAKE_TOOLCHAIN_FILE=""
	parseArgs $@

	pushd $LIBS_DIR/${LIB}
	if [ "$BUILDSYSTEM" == "cmake" ]; then
		mkdir -p $CMAKE_BUILD_DIR
		pushd $CMAKE_BUILD_DIR
		cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE ../
		make -j$(getconf _NPROCESSORS_ONLN)
		$(find . -name "lib*.so*" | xargs cp -Pt $BUILD_DIR/) && true
		popd
	else
		CONF_FLAGS="${CONF_FLAGS//#space#/ }" #replace all #space# with spaces
		CONF_FLAGS="${CONF_FLAGS//#equal#/=}" #replace all #equal#  with =
		CFLAGS=$CFLAGS ./configure $CONF_FLAGS
		make -j$(getconf _NPROCESSORS_ONLN)
		find . -name "lib*.so*" | xargs cp -Pt $BUILD_DIR/
	fi
	popd
}
