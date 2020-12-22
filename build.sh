#!/bin/bash -xe
set -xe

source .scripts/utils.sh

#docker build --no-cache -t leila .

function dockerImageExists()
{
	parseArgs $@
	
	RES=$(docker inspect --type=image $IMAGE_NAME) && true
	if [ "$RES" == "[]" ]; then
		RES="false"
	else
		RES="true"
	fi
}

function buildBaseImage()
{
	rm -f Dockerfile
	ln -s Dockerfile.base Dockerfile
	docker build -t leila-base .
}

function buildLeilaImage()
{
	mkdir -p .cache
	if [ -d ~/.leila/cache ]; then 
		cp -f ~/.leila/cache/* .cache/
	fi
	rm -f Dockerfile
	ln -s Dockerfile.leila Dockerfile
	docker build -t leila .
}

##################################################################
if [ "$1" == "clean" ]; then
	docker system prune -af
elif [ "$1" == "base" ]; then
	buildBaseImage
elif [ "$1" == "all" ]; then
	buildBaseImage
	buildLeilaImage
else
	dockerImageExists IMAGE_NAME="leila-base" RES=0
	if [ $RES == "false" ]; then
		buildBaseImage
		echo "building base image"
	fi
	buildLeilaImage
fi

