FROM tensorflow/tensorflow:latest-gpu-jupyter

EXPOSE 443
EXPOSE 80
COPY runscript.sh /tmp
COPY etc.apache2.tar.xz /tmp
COPY self-signed.crt /tmp
COPY self-signed.key /tmp
COPY libGL.so.1.5.0 libGL.so.1 libGL.so /tmp/
RUN /tmp/runscript.sh
ENV HOME /home/dev
ENV PATH="${PATH}:/home/dev/Downloads/cmake-3.12.2-Linux-x86_64/bin:/usr/games"
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
USER dev
WORKDIR /home/dev
COPY configure-container.sh /home/dev/configure-container.sh
