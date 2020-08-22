## OpenPLC - IEC 61131-3 compatible open source PLC

For use on Raspberry PI, inspired by https://github.com/HilscherAutomation/netPI-openplc which can be used in an industrial content on netPI with Raspberry PI 3B hardware inside, but better hardware layout.

### Debian with OpenPLC V3 runtime, SSH server and user root

The image provided hereunder deploys a container with OpenPLC V3 runtime. OpenPLC is a completely free and standardized software basis to create programmable logic controllers. The editor that comes extra lets you program in the languages Ladder Diagram (LD), Instruction List (IL), Structured Text (ST), Function Block Diagram (FBD) and Sequential Function Chart (SFC) in accordance with the IEC 61131-3.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), created user 'root' and peinstalled OpenPLC_v3 project from [here](https://github.com/thiagoralves/OpenPLC_v3)

Using OpenPLC works in conjunction with a [PLCOpen Editor](http://www.openplcproject.com/plcopen-editor) that lets you writing PLC programs offline to import them into the runtime. This tool has to be installed under Linux or Windows separately.

Additional information about the OpenPLC project can be retrieved [here](http://www.openplcproject.com/).

Questions can be directed to the [official OpenPLC forum](https://openplc.discussion.community/)

#### Container prerequisites

##### Port mapping

For remote login (not necessary for default usage) to the container across SSH the container's SSH port `22` needs to be mapped to any free host port.

To allow the access to the OpenPLC web interface over a web browser the container TCP port `8080` needs to be exposed to any free host port.

By default OpenPLC supports Modbus TCP server functionality using the default port `502`. This port should be exposed to host port `502` (be compatible with standard Modbus TCP clients).

##### Privileged mode

Only the privileged mode option lifts the enforced container limitations to allow usage of all host features in a container.

##### Host device

To grant access to the gpio interface the `/dev/gpiomem` host device needs to be exposed to the container.

#### Getting started

##### Installing Docker

First of all installing docker is required on Raspberry Pi. For running docker on Raspberry Pi, follwing parameters are needed to be added in /boot/cmdline.txt by
`sudo nano /boot/cmdline.txt`:

```
cgroup_enable=memory cgroup_memory=1
```

Now a reboot is required by `sudo reboot`

Now docker can be installed by
```
sudo apt-get update
sudo apt-get dist-upgrade
curl -sSL -o install.sh https://get.docker.com
sh install.sh
sudo usermod -aG docker pi
```

##### Installing Portainer

It makes sense to install a docker management on Raspberry Pi hosted on a website. This can be done by installing Portainer:

```
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer
```

Now docker can be managed via [http://raspberrypi.local:9000/](http://raspberrypi.local:9000/)

##### Installing other Containers

See official Images for supported architectures:
[https://hub.docker.com/r/arm32v5](arm32v5) in theory all Raspberry Pi models
[https://hub.docker.com/r/arm32v6](arm32v6) like Raspberry Pi Zero
[https://hub.docker.com/r/arm32v7](arm32v7) like Raspberry Pi 3 or 4
[https://hub.docker.com/r/arm64v8](arm64v8) like Raspberry Pi 4 in 64-bit mode

Old Images:
[https://hub.docker.com/u/armhf](armhf) in theory all Raspberry Pi models

Available Images on Balena:
[https://www.balena.io/docs/runtime/resin-base-images/](resin-base-images)

##### Building this container

Move into the root of this folder where the Dockerfile is placed. And run

```
sudo apt-get update
sudo apt-get install git
git clone https://github.com/schreinerman/rpi-openplc-docker.git
cd rpi-openplc-docker
docker build --tag ioexpert/openplc:1.0 .
```

After successful build, run following command (SSH port is mapped o 23):

```
docker run --privileged --restart=always -v /dev/gpiomem:/dev/gpiomem --publish 8080:8080 --publish 502:502 --publish 23:22 --detach --name bb ioexpert/openplc:1.0
```

#### Accessing

The container starts an SSH server as well as the OpenPLC runtime automatically when started.

Just in case your want to open a terminal connection to it with an SSH client such as [putty](http://www.putty.org/) using Raspberry PI's IP address at your mapped port 22. Use the credentials `root` as user and `root` as password when asked and you are logged in as root user `root`.

The default usage is interacting with the OpenPLC runtime across its web GUI using a web browser. To access the web GUI use http://raspberrypi.local:8080)

##### OpenPLC runtime

Enter the default user and password `openplc` when asked during your web login. (The password can be changed or new users be added in the `Settings` menu pane later).

#### Automated build

The project complies with the scripting based [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build the image output file. Using this method is a precondition for an [automated](https://docs.docker.com/docker-hub/builds/) web based build process on DockerHub platform.

DockerHub web platform is x86 CPU based, but an ARM CPU coded output file is needed for Raspberry systems. This is why the Dockerfile includes the [balena](https://balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/) steps.

#### License

View the license information for the software in the project. As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
