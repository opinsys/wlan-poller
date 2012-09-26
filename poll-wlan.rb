#!/usr/bin/env ruby

require "pp"
require "socket"

HOST = "eventlog"
PORT = 3858
POLL_INTERVAL = 50


def device_list
  output =  `hostapd_cli all_sta`
  if not $?.success?
    STDERR.puts "failed to execute 'hostapd_cli all_sta'"
    return []
  end

  return output.split("\n").select do |line|
    line.start_with? "dot11RSNAStatsSTAAddress"
  end.map do |line|
    line.split("=")[1]
  end
end


class DevicePoller

  def initialize(host, port, interval)
    @sock = UDPSocket.new
    @sock.connect host, port
    @interval = interval
  end

  def poll
    @devices = device_list
  end

  def current_hashkey
    @devices.reduce do |memo, mac|
      memo+mac
    end
  end


  def dirty
    @sent_hashkey != current_hashkey
  end

  def loop
    while true
      poll
      send if dirty
      sleep @interval
    end
  end

  def send

    packet = <<EOF
type:wlan
wlan_event:hotspot_state
connected_devices:[#{ @devices.join(",") }]
hostname:#{ Socket.gethostname }
EOF
    puts "#{ Time.now } Sending #{ packet.split("\n").join("|") }"
    @sock.send packet, 0
    @sent_hashkey = current_hashkey
  end

end


if __FILE__ == $0
  poller = DevicePoller.new HOST, PORT, POLL_INTERVAL
  poller.loop()
end
