#!/bin/bash -xe
set -xe

source $(dirname `realpath $0`)/utils.sh

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
function installPublicPrivateKeys()
{	
	sudo chown -R dev:dev ~/.ssh
	rm -fr ~/.ssh/id_rsa
	ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
}

function configureOpenGl()
{
	pushd /
	sudo mv -f /tmp/gl/* /usr/lib/x86_64-linux-gnu/
	popd
}

function installGoogleChromeBrowser()
{
	local TMP_CACHE="/tmp/.leila/cache"
	pushd $TMP_CACHE
	if [ ! -f "google-chrome-stable_current_amd64.deb" ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	fi

	sudo apt --fix-broken install
	sudo dpkg -i $TMP_CACHE/google-chrome-stable_current_amd64.deb
	popd
}

function installCMake()
{
	CMAKE_VERSION="3.19.0-rc2"

	local TMP_CACHE="/tmp/.leila/cache"
	pushd $TMP_CACHE
	if [ ! -f "cmake-$CMAKE_VERSION.tar.gz" ]; then
		local URL="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz"
		wget $URL
	fi

	tar -xzvf cmake-$CMAKE_VERSION.tar.gz
	pushd cmake-$CMAKE_VERSION
	./bootstrap
	make -j$(getconf _NPROCESSORS_ONLN) install
	popd
	
	popd
}

function main()
{
	makeUserDirectories
	createUser
	configureScriptsDirectory
	configureSelfSignedCertificate
	installPublicPrivateKeys
	configureOpenGl
	installGoogleChromeBrowser
	installCMake
	rm -fr /tmp/.leila
}

main
