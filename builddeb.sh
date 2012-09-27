#!/bin/sh

set -eu

rm -rf wlan-poller_build/ || true

mkdir wlan-poller_build
cp -r wlan-poller/Makefile wlan-poller/wlan-poller.rb wlan-poller/debian/ wlan-poller_build/
cd wlan-poller_build/
debuild -us -uc

