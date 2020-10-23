#!/bin/bash -x
#
#
set -x

function main()
{
	if [ "$DOCKERUSER" = "" ]; then echo "Environment variable DOCKERUSER was not set during docker run command. $DOCKERUSER"; exit -1; fi

	installSshKeys
	configureGit
	configureUserDirectory "Downloads"
	configureUserDirectory "Documents"
	configureCMake
	configureSelfSignedCertificate
	configureMysql
	configureApache2
	configureQtCreator
	configureOpenGl
}

function installSshKeys()
{
    echo "installSshKeys"
	if [ ! -d "/home/dev/$DOCKERUSER/.ssh" ]; then echo "/home/dev/$DOCKERUSER/.ssh does not exist"; else
		echo "setting link to .ssh"
		ln -s /home/dev/$DOCKERUSER/.ssh /home/dev/.ssh;
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
    sudo cp -nr /home/dev/$1/* /home/dev/$DOCKERUSER/$1/
    rm -fr /home/dev/$1
    ln -s /home/dev/$DOCKERUSER/$1 /home/dev/$1
}

function configureCMake()
{
	pushd /home/dev/Downloads
	if [ ! -d "cmake-3.15.0-Linux-x86_64" ]; then
		wget "https://cmake.org/files/v3.15/cmake-3.15.0-Linux-x86_64.tar.gz"
		tar -xzvf cmake-3.15.0-Linux-x86_64.tar.gz
	fi
	popd
}

function configureSelfSignedCertificate()
{
	pushd /home/dev/$DOCKERUSER/.ssh/
	if [[ ! -f "self-signed.crt" || ! -f "self-signed.key" ]]; then
		openssl req -new -x509 -days 365 -sha1 -newkey rsa:1024 -nodes -keyout server.key -out server.crt -subj '/O=Company/OU=Department/CN=osletek.com'
		mv server.crt self-signed.crt
		mv server.key self-signed.key
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
	sudo tar xvf /tmp/etc.apache2.tar.xz
	popd
	sudo usermod -a -G dev www-data
	sudo apachectl start
	#sudo tail -F /var/log/apache2/error.log
}

function configureOpenGl()
{
	pushd /
	sudo cp /tmp/libGL.so* /usr/lib/x86_64-linux-gnu/
	sudo rm -fr /tmp/libGL.so*
	popd
}


function installGoogleChromeBrowser()
{
	if [ -f "/tmp/google-chrome-stable_current_amd64.deb" ]; then 
		sudo apt --fix-broken install
		sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb
		sudo rm -f /tmp/google-chrome-stable_current_amd64.deb
	fi 
	#google-chrome-stable https://www.osletek.com/bluejay  2&>/dev/null &
}

function configureQtCreator()
{
	sudo ln -s /home/dev/$DOCKERUSER/work.git/bluejay.docker/qtcreator.sh /usr/local/bin/qtcreator
	sudo rm -fr /home/dev/.config
	sudo ln -s /home/dev/$DOCKERUSER/.config /home/dev/.config
}

main
