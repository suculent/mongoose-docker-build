# Stage 1: build the mos CLI from source.
#
# The `mos-latest` .deb from the mongoose-os PPA is a **go1.13.8** binary,
# frozen since 2023-03-14, so every Go stdlib CVE fixed since then is reported
# against this image and no apt upgrade can move it -- the stdlib is linked
# into that prebuilt binary, not provided by the distro. Upstream publishes no
# newer build (mos master is unchanged since 2023-03-13), so compiling the same
# tree with a current toolchain is the only way to re-link the stdlib.
#
# The source is our fork, not upstream. Upstream's tree still carries its
# 2021 dependency set -- x/crypto, go-git v5.4.2, grpc v1.40, x/net -- which
# grype scores at 77 findings, 11 of them critical, and upstream has published
# nothing since 2023-03-13 to fix it. suculent/mos @ thinx/deps-2026-09 is
# master with those nine modules bumped to current and three latent
# format-string bugs fixed; it builds firmware identically. See that commit
# for the full rationale and the go-git regression test it adds.
#
# Repin by SHA after any fork change -- never track the branch name, or the
# image stops being reproducible.
FROM golang:1.27.1 AS mosbuild

ARG MOS_REPO=https://github.com/suculent/mos
ARG MOS_REF=f612a4c098ad669ae76fb5e767ae18141ea36a50

# mos links libusb/libftdi/libudev through cgo (gousb, cesanta/hid,
# cesanta/go-serial), and its Makefile generates version/version.go with
# tools/fw_meta.py, hence python3.
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends \
      python3 pkg-config libusb-1.0-0-dev libftdi1-dev libudev-dev git \
 && rm -rf /var/lib/apt/lists/*

RUN git clone -q ${MOS_REPO} /src \
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
