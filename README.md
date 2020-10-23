# leila.docker
Docker container based on tensorflow/tensorflow:latest-gpu-jupyter.
Comes with TensorFlow pre-installed.
Requires NVIDIA GPU on host machine.

## Get the files, build the Docker image, then enter it:
```bash
git clone https://github.com/jambamamba/leila.docker.git
cd leila.docker
./builddocker.sh
./enterdocker.sh
```
If it fails to build, then try 
```bash
docker pull tensorflow/tensorflow:latest-gpu-jupyter
```
then follow with the builddocker.sh script above

If it asks for password when you run enterdocker.sh script, the password is:
```bash
dev
```


## Just building the Docker container
```bash
./builddocker.sh
```

## Entering the Docker container
```bash
./enterdocker.sh
```

## Exiting the container
exit 
(from inside the container)

## Re-entering a running container
```bash
./attachdocker.sh
```

