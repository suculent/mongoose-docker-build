#!/usr/bin/env bash

set -e

pwd

cd /opt/mongoose-builder

pwd

ls

# TODO: fetch arch!

echo "WARNING, currently defaults to ESP32/ESP8266 platform only, must be parametrized later."
ARCH='ESP8266'
if [[ -z $(cat ./mos.yml | grep "esp32") ]]; then
  ARCH='ESP32'
fi

/root/.mos/bin/mos update
/root/.mos/bin/mos build --arch=${ARCH}
