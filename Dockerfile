FROM tensorflow/tensorflow:latest-gpu-jupyter

EXPOSE 443
EXPOSE 80
COPY .scripts/build-image.sh /tmp/
RUN /tmp/build-image.sh
USER dev
WORKDIR /home/dev
ENV HOME /home/dev
ENV PATH="${PATH}:/usr/games"
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
ADD .certs /tmp/.certs
ADD .scripts /tmp/.scripts
