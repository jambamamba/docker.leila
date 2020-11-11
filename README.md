# leila.docker
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
git clone https://github.com/jambamamba/leila.docker.git
cd leila.docker
./builddocker.sh
./enterdocker.sh
```
When it asks for password when you run enterdocker.sh script, the password is:
```bash
dev
```

## Just building the Docker image
```bash
./builddocker.sh
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

