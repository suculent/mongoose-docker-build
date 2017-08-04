FROM ubuntu
MAINTAINER suculent

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc curl \
 && curl -fsSL https://mongoose-os.com/downloads/mos/install.sh | /bin/bash
 
RUN mkdir /opt/mongoose-firmware
WORKDIR /opt/mongoose-firmware
COPY cmd.sh /opt/
CMD /opt/cmd.sh
