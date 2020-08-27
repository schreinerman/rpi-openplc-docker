#use latest armv7hf compatible debian version from group resin.io as base image
#
# use armv5e  for Raspberry 1, Zero, Zero W
# use armv7hf for Raspberry 2,3,4
FROM balenalib/armv5e-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="info@io-expert.com" \
      version="V1.0.0" \
      description="Open-PLC - IEC 61131-3 compatible open source PLC"

#version
ENV IOEXPERT_OPENPLC 1.0.0

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
                    wiringpi \
                    pkg-config \
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

#SSH port 22,  default OpenPLC port 8080 and Modbus TCP 502
EXPOSE 22 8080 502

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
