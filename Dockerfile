FROM ubuntu

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc curl

WORKDIR /root/

COPY install.sh /root/install.sh
RUN bash /root/install.sh

RUN mos version
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
