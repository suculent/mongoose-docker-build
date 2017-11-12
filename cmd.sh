#!/usr/bin/env bash

set -e

ls

# TODO: fetch arch!

echo "WARNING, currently defaults to ESP32/ESP8266 platform only, must be parametrized later."
ARCH='esp8266'
if [[ -z $(cat ./mos.yml | grep "esp32") ]]; then
  ARCH='esp32'
fi

/root/.mos/bin/mos update

echo "Building in clouds..."
/root/.mos/bin/mos build --arch=${ARCH}

# Report build status using logfile
if [[ $? == 0 ]]; then
  echo "THiNX BUILD SUCCESSFUL."
else
  echo "THiNX BUILD FAILED: $?"
fi