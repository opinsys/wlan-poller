#!/bin/sh

# Run from parent directory!

FILES="wlan-poller/Makefile wlan-poller/wlan-poller.rb wlan-poller/debian/"

set -eu

# Remove previous build
rm -rf wlan-poller_build/ || true

mkdir wlan-poller_build

cp -r $FILES wlan-poller_build/

cd wlan-poller_build/

debuild -us -uc

