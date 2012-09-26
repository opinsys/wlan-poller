#!/bin/sh

mkdir wlan-poller_build
cp -r wlan-poller/Makefile wlan-poller/wlan-poller.rb wlan-poller/debian/ wlan-poller_build/
cd wlan-poller_build/
debuild -us -uc

