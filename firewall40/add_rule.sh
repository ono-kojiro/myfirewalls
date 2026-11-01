#!/bin/sh

set -eu

#debug="-d"
debug=""

opncli firewall filter add_rule \
   $debug \
   enabled=1 \
   action=pass \
   interface=wan \
   direction=in \
   ipprotocol=inet \
   protocol=ICMP \
   source_net=any \
   destination_net=wanip \
   description="allow PING from wan to this firewall" \
   quick=1 \
   statetype=keep \
   categories=red \
   sequence=111

opncli firewall filter add_rule \
   $debug \
   enabled=1 \
   action=pass \
   interface=opt3 \
   direction=in \
   ipprotocol=inet \
   protocol=ICMP \
   source_net=any \
   destination_net=opt3ip \
   description="allow PING from opt3 to this firewall" \
   quick=1 \
   statetype=keep \
   categories=blue \
   sequence=120

opncli firewall filter add_rule \
   $debug \
   enabled=1 \
   action=pass \
   interface=opt3 \
   direction=in \
   ipprotocol=inet \
   protocol=TCP \
   source_net=any \
   destination_net=192.168.1.72 \
   destination_port=636 \
   description="allow LDAPS from opt3" \
   quick=1 \
   statetype=keep \
   categories=blue \
   sequence=130

opncli firewall filter add_rule \
   $debug \
   enabled=1 \
   action=pass \
   interface=opt1 \
   direction=in \
   ipprotocol=inet \
   protocol=TCP \
   source_net=any \
   destination_net=any \
   destination_port=1234 \
   description="allow 1234 port" \
   quick=1 \
   statetype=keep \
   categories=blue \
   sequence=135

opncli firewall filter add_rule \
   $debug \
   enabled=1 \
   action=pass \
   interface=wan \
   direction=in \
   ipprotocol=inet \
   protocol=ICMP \
   source_net=any \
   destination_net=wanip \
   description="allow PING from wan to this firewall 222" \
   quick=1 \
   statetype=keep \
   categories=blue \
   sequence=222

opncli firewall filter apply

