containerid=$(docker ps -a | grep leila | head -n1 | cut -d " " -f1); docker exec -it $containerid /bin/bash

