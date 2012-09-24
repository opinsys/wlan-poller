#!/usr/bin/env ruby

require "pp"
require "socket"

sock = UDPSocket.new
sock.connect "eventlog", 3858

output =  `hostapd_cli all_sta`
if not $?.success?
  STDERR.puts "failed to execute 'hostapd_cli all_sta'"
  exit 1
end

devices = output.split("\n").select do |line|
  line.start_with? "dot11RSNAStatsSTAAddress"
end.map do |line|
  line.split("=")[1]
end.join(",")

packet = <<EOF
type:wlan
wlan_event:hotspot_state
connected_devices:[#{ devices }]
hostname:#{ Socket.gethostname }
EOF

puts packet
sock.send packet, 0
