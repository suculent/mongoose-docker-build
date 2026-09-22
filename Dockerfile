# Stage 1: build the mos CLI from source.
#
# The `mos-latest` .deb from the mongoose-os PPA is a **go1.13.8** binary,
# frozen since 2023-03-14, so every Go stdlib CVE fixed since then is reported
# against this image and no apt upgrade can move it -- the stdlib is linked
# into that prebuilt binary, not provided by the distro. Upstream publishes no
# newer build (mos master is unchanged since 2023-03-13), so compiling the same
# tree with a current toolchain is the only way to re-link the stdlib.
#
# MOS_REF is master@2023-03-13, the commit the PPA binary was cut from
# (mos reports build version 202303131403 vs the .deb's 202303141315).
FROM golang:1.25.13 AS mosbuild

ARG MOS_REF=b44964e63a926c1ac2af7496c8749555d6c3e166

# mos links libusb/libftdi/libudev through cgo (gousb, cesanta/hid,
# cesanta/go-serial), and its Makefile generates version/version.go with
# tools/fw_meta.py, hence python3.
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends \
      python3 pkg-config libusb-1.0-0-dev libftdi1-dev libudev-dev git \
 && rm -rf /var/lib/apt/lists/*

RUN git clone -q https://github.com/mongoose-os/mos /src \
 && cd /src \
 && git checkout -q ${MOS_REF} \
 && make mos \
 && ./mos version \
 && cp ./mos /usr/local/bin/mos

# Docker Hardened Image base (CIS-compliant, DHI-maintained Debian 13 "trixie").
# The `-dev` variant is required: cmd.sh shells out to the toolchain at run
# time, and the runtime variant ships no package manager and no compiler.
FROM dhi.io/debian-base:trixie-dev

ENV DEBIAN_FRONTEND=noninteractive

# libusb-1.0-0 + libftdi1-2 are what the PPA package used to pull in as its
# Depends; the cgo-linked mos binary needs them at run time (libudev1 arrives
# with libusb).
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
bc \
ca-certificates \
curl \
gcc \
git \
gnupg \
make \
srecord \
unzip \
wget \
xz-utils \
libusb-1.0-0 \
libftdi1-2 \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root/

COPY --from=mosbuild /usr/local/bin/mos /usr/bin/mos

RUN mos version
RUN mkdir /opt/mongoose-builder
WORKDIR /opt/mongoose-builder
COPY cmd.sh /opt/
CMD /opt/cmd.sh
