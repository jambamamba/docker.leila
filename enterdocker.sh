#!/bin/bash -xv
set -xv

pushd ~
docker run --shm-size=256m --rm -e DOCKERUSER=$USER -e DISPLAY=$DISPLAY -e DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS -e GITUSER="$(git config --get user.name)" -e GITEMAIL="$(git config --get user.email)" -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/dev/.Xauthority --net=host -v $PWD:/home/dev/$USER -v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket -v /run/user/1000:/run/user/1000 --name leila --cap-add=SYS_PTRACE --privileged --hostname osletek.com --add-host osletek.com:127.0.0.1 --add-host www.osletek.com:127.0.0.1 -p 443:443 -it leila bash -c "/tmp/.scripts/run-container.sh"
popd