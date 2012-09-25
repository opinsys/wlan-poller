#!/usr/bin/env ruby

require "pp"
require "socket"

HOST = "eventlog"
PORT = 3858


def device_list
  output =  `hostapd_cli all_sta`
  if not $?.success?
    STDERR.puts "failed to execute 'hostapd_cli all_sta'"
    exit 1
  end

  devices = output.split("\n").select do |line|
    line.start_with? "dot11RSNAStatsSTAAddress"
  end.map do |line|
    line.split("=")[1]
  end
end

class DevicePoller

  def initialize(host, port)
    @sock = UDPSocket.new
    @sock.connect host, port
  end

  def poll
    @devices = device_list

    hashkey = @devices.reduce do |memo, mac|
      memo+mac
    end

    if @prev_hashkey != hashkey
      @prev_hashkey = hashkey
      send
    end

  end

  def send

    packet = <<EOF
type:wlan
wlan_event:hotspot_state
connected_devices:[#{ @devices.join(",") }]
hostname:#{ Socket.gethostname }
EOF
    puts packet
    @sock.send packet, 0
  end

  def loop
    while true
      poll
      sleep 60
    end
  end

end


if __FILE__ == $0
  poller = DevicePoller.new HOST, PORT
  poller.loop()
end
