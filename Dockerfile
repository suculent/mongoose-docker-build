FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq \
bc \
ca-certificates \
curl \
gcc \
git \
gnupg \
make \
srecord \
software-properties-common \
unzip \
wget \
xz-utils

WORKDIR /root/

# Add the mongoose-os/mos PPA manually. We fetch the signing key over HTTPS
# instead of `add-apt-repository`, whose hkp keyserver lookup intermittently
# times out in CI ("Error: retrieving gpg key timed out").
RUN curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x914DB695828DCC38891C7AA1FD31EFE61A213823" \
      | gpg --dearmor -o /usr/share/keyrings/mongoose-os-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mongoose-os-archive-keyring.gpg] https://ppa.launchpadcontent.net/mongoose-os/mos/ubuntu focal main" \
      > /etc/apt/sources.list.d/mongoose-os.list \
    && apt-get update \
    && apt-get install -y mos-latest

RUN mos version
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
