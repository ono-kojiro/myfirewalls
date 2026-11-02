#!/bin/sh

opncli firewall alias add_item \
    name=host_ldapserver \
    type=host \
    content=192.168.1.72 \
    enabled=1 \
    description="Alias of LDAP Server"

opncli firewall alias add_item \
    name=port_1234 \
    type=port \
    content=1234 \
    enabled=1 \
    description="Alias of port 1234"

opncli firewall alias reconfigure

