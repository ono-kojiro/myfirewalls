#!/bin/sh

echo "read user information from ./.snmpuser"

. ./.snmpuser

opncli netsnmp user add_user \
    username=$username \
    password=$password \
    enckey=$enckey \
    enabled=1

opncli netsnmp service reconfigure


