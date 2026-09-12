#!/bin/sh

ifaces="opt1 opt2 opt3"

for iface in $ifaces; do
  IFACE=`echo $iface | tr '[:lower:]' '[:upper:]'`

  opncli firewall filter add_rule \
    enabled=1 \
    action=pass \
    interface=$iface \
    direction=in \
    ipprotocol=inet \
    protocol=any \
    source_net=$iface \
    destination_net=any \
    descr="allow $IFACE to any rule" \
    quick=1 \
    statetype=keep

done

opncli firewall filter apply

