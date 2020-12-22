# docker.leila
Docker container based on tensorflow/tensorflow:latest-gpu-jupyter.
Comes with TensorFlow pre-installed.
Requires NVIDIA GPU on host machine.

To confirm if your PC has a GPU
```bash
lspci | grep VGA
```
It should read something like this "NVIDIA Corporation GP104 [GeForce GTX 1080] (rev a1)"

## Get the files, build the Docker image, then start the Docker container:
```bash
git clone https://github.com/jambamamba/docker.leila.git
cd docker.leila
./build.sh
./enterdocker.sh
```
When it asks for password when you run enterdocker.sh script, the password is:
```bash
dev
```

## Building the Docker image
```bash
./build.sh
```

### More commands
```bash
./build.sh clean #this will purge all docker images from your system, not just docker.leila!
./build.sh base  #just build the first layer (that installs Ubuntu packages)
./build.sh all   #build all layers
./build.sh       #builds base layer if missing, then builds final layer on top, otherwise just builds final layer 
```

## Entering the Docker container
```bash
./enterdocker.sh
```

## Exiting the container
```bash
exit 
```
(from inside the container)

## Re-entering a running container
```bash
./attachdocker.sh
```

## Permission error when entering container

If you get permission error

```bash
sudo groupadd docker
sudo usermod -aG docker ${USER}
```

Then logout, and login again.

## Cannot run GUI apps inside container

If you cannot run GUI apps inside the Docker container, like gedit, then from host you may need to grant X-server permission so your Docker container GUI app can run:

```bash
xhost +
```
