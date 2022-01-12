FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq \
bc \
curl \
gcc \
git \
make \
srecord \
unzip \
wget \
xz-utils

WORKDIR /root/

COPY install.sh /root/install.sh
RUN bash /root/install.sh

RUN mos version
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
