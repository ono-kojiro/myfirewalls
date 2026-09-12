#!/bin/sh

opncli firewall filter add_rule \
  enabled=1 \
  action=pass \
  interface=wan \
  direction=in \
  ipprotocol=inet \
  protocol=ICMP \
  source_net=any \
  destination_net=wanip \
  descr="allow PING from wan to this firewall" \
  quick=1 \
  statetype=keep \
  sequence=111

opncli firewall filter apply

