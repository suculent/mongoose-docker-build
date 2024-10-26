FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq \
bc \
curl \
gcc \
git \
make \
srecord \
software-properties-common \
unzip \
wget \
xz-utils

WORKDIR /root/

RUN add-apt-repository ppa:mongoose-os/mos \
    && apt-get update \
    && apt-get install -y mos-latest

RUN mos version
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
