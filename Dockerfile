FROM ubuntu
MAINTAINER suculent

RUN apt-get update -qq && apt-get install -qq -y wget unzip git make python-serial srecord bc xz-utils gcc curl \
 && curl -fsSL https://mongoose-os.com/downloads/mos/install.sh | /bin/bash

RUN /root/.mos/bin/mos update
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
