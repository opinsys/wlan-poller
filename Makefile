
prefix ?= /usr/local

all:

install:
	install -o root -g root -m 755 wlan-poller.rb \
		$(DESTDIR)$(prefix)/bin/wlan-poller
