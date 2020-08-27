#use latest compatible debian version from group resin.io as base image
#
# use balenalib/raspberry-pi-debian:buster  for Raspberry 1, Zero, Zero W
# use balenalib/armv7hf-debian:buster for Raspberry 2,3,4
FROM balenalib/armv7hf-debian:buster

#dynamic build arguments coming from the /hooks/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/schreinerman/rpi-openplc-docker" \
      org.label-schema.vcs-ref=$VCS_REF

#version
ENV IOEXPERT_ARMV7_OPENPLC_VERSION 1.3.0

#labeling
LABEL maintainer="info@io-expert.com" \
      version=$IOEXPERT_ARMV7_OPENPLC_VERSION \
      description="OpenPLC V3"


#labeling
LABEL maintainer="info@io-expert.com" \
      version="V1.0.0" \
      description="Open-PLC - IEC 61131-3 compatible open source PLC"

#copy init.d files
COPY "./init.d/*" /etc/init.d/

#init atitude, install ssh, give user "root" a password
RUN apt-get update  \
    && apt-get install wget \
    && wget https://archive.raspbian.org/raspbian.public.key -O - | apt-key add - \
    && echo 'deb http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi' | tee -a /etc/apt/sources.list \
    && wget -O - http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo apt-key add - \
    && echo 'deb http://archive.raspberrypi.org/debian/ stretch main ui' | tee -a /etc/apt/sources.list.d/raspi.list \
    && apt-get update \
    && apt-get install -y openssh-server \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd

#install required packages and tools
RUN apt-get install git \
                    make \
                    autotools-dev \
                    autoconf \
                    automake \
                    cmake \
                    bison \
                    flex \
                    build-essential \
                    python-dev \
                    python-pip \
                    wget \
                    libtool \
                    pkg-config \
                    libssl-dev \
                    libfreetype6-dev \
                    wiringpi \
                    binutils

#install required python software
RUN python -m pip install --upgrade pip \
    && pip install --upgrade setuptools

#clone OpenPLC source from git repo
RUN git clone https://github.com/thiagoralves/OpenPLC_v3.git

#copy customized hardware layers
COPY "./hardware_layers/*" "./OpenPLC_v3/webserver/core/hardware_layers/"

#compile and install OpenPLC
RUN cd OpenPLC_v3 \
    && ./install.sh docker

#clean-up
RUN rm -rf /tmp/* \
 && apt remove git \
 && apt autoremove \
 && apt upgrade \
 && rm -rf /var/lib/apt/lists/*

#SSH port 22,  default OpenPLC port 8080 and Modbus TCP 502
EXPOSE 22 8080 502

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM