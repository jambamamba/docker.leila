# leila.docker
Docker container based on tensorflow/tensorflow:latest-gpu-jupyter.
Comes with TensorFlow pre-installed.
Requires NVIDIA GPU on host machine.

## Building the Docker container
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

