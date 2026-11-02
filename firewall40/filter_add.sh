#!/bin/sh
set -eu
debug=""
ifaces="wan opt1 opt2 opt3"
sequence="100"

for iface in $ifaces; do
  opncli firewall filter add_rule \
    $debug \
    enabled=1 \
    action=pass \
    interface=$iface \
    direction=in \
    ipprotocol=inet \
    protocol=ICMP \
    source_net=any \
    destination_net=any \
    description="allow PING from $iface" \
    quick=1 \
    statetype=keep \
    categories=red \
    sequence=$sequence

  sequence=$(expr $sequence + 1)
done

opncli firewall filter add_rule \
    $debug \
    enabled=1 \
    action=pass \
    interface=opt2 \
    direction=in \
    ipprotocol=inet \
    protocol=TCP \
    source_net=192.168.42.0/24 \
    destination_net=192.168.13.0/24 \
    destination_port=9999 \
    description="allow VIP connection from opt2" \
    quick=1 \
    statetype=keep \
    categories=red \
    sequence=200

opncli firewall filter apply

