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
	pushd /
	sudo tar xvf "/tmp/etc.apache2.tar.xz"
	popd
	sudo rm -f "/tmp/etc.apache2.tar.xz"
	sudo usermod -a -G dev www-data
	sudo apachectl start
	#sudo tail -F /var/log/apache2/error.log
}

function configureQtCreator()
{
	local SCRIPTS_DIR="/home/dev/.scripts"
	sudo cp $SCRIPTS_DIR/qtcreator.sh /usr/local/bin/qtcreator
	sudo rm -fr /home/dev/.config
	sudo ln -s /home/dev/$DOCKERUSER/.config /home/dev/.config
}

function updateBinLibPaths()
{
	echo "/home/dev/lib" > /tmp/leila.conf
	sudo mv /tmp/leila.conf /etc/ld.so.conf.d/leila.conf
	sudo ldconfig

	local BIN_DIR="/home/dev/bin"
	mkdir -p $BIN_DIR
	local LIB_DIR="/home/dev/lib"
	mkdir -p $LIB_DIR
	local SCRIPTS_DIR="/home/dev/.scripts"
	mkdir -p $SCRIPTS_DIR
	export PATH=$PATH:$SCRIPTS_DIR:$BIN_DIR

    sudo chown -R dev:dev $BIN_DIR
    sudo chown -R dev:dev $LIB_DIR
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
	updateBinLibPaths
	
	local SCRIPTS_DIR="/home/dev/.scripts"
	rm $SCRIPTS_DIR/build-image.sh

# copy built libs back to directory so next time its faster to build docker image:
#sudo rsync -uav ~/.libs ~/$DOCKERUSER/leila.docker/

}

main
bash