FROM tensorflow/tensorflow:latest-gpu-jupyter

EXPOSE 443
EXPOSE 80
ADD .certs /tmp/.certs
ADD .scripts /tmp/.scripts
ADD .libs /home/dev/.libs
WORKDIR /home/dev
ENV HOME /home/dev
ENV PATH="${PATH}:/usr/games"
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
RUN /tmp/.scripts/build-image.sh
USER dev
