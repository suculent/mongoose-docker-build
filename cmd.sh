#!/usr/bin/env bash

set -e

ls

echo "WARNING, currently defaults to ESP32/ESP8266 platform only, must be parametrized later."

# mos.yml declares its target with `platform:` (manifest v2) or `arch:` (v1), so
# read that key. The previous probe grepped the whole file for the string
# "esp32" and then assigned the *opposite* of what it found: a project
# declaring esp32 was built as esp8266 and vice versa. It also matched any
# incidental mention -- `conds: - when: mos.platform == "esp32"` appears in
# projects that merely support esp32 as an alternative, including the upstream
# demo app -- so even un-inverted the grep would pick the wrong target.
ARCH=$(sed -n -E 's/^[[:space:]]*(platform|arch):[[:space:]]*"?([A-Za-z0-9_-]+)"?.*/\2/p' ./mos.yml | head -n1)

if [ -z "${ARCH}" ]; then
  ARCH='esp8266'
  echo "No platform/arch declared in mos.yml, defaulting to ${ARCH}."
fi

echo "Building for platform: ${ARCH}"

# `mos update` used to self-update the CLI into /root/.mos/bin -- a path that has
# never existed in this image, so under `set -e` the entrypoint died right here,
# before it built anything. The command is dead upstream anyway: it 404s on
# mongoose-os.com/downloads/mos-latest/version.json, and the PPA build shelled
# out to `sudo apt-get`, which is not installed either. The image pins its own
# mos (built from source in the Dockerfile), so there is nothing to update.

echo "Building in clouds..."

# `set -e` is on, so a failing `mos build` used to kill the script right here:
# RESULT was never assigned, and the status line below -- which is what THiNX
# scrapes out of the build log -- never printed. Capture the status instead,
# report it, and still exit non-zero so the caller sees the failure.
RESULT=0
mos build --arch=${ARCH} || RESULT=$?

echo ""

# Report build status using logfile
if [[ $RESULT == 0 ]]; then
  echo "THiNX BUILD SUCCESSFUL."
else
  echo "THiNX BUILD FAILED: $RESULT"
fi

exit $RESULT
