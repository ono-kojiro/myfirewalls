#!/bin/sh

opncli core firmware install --pkg_name=os-net-snmp

opncli netsnmp general set enabled=1
opncli netsnmp service reconfigure

opncli netsnmp service start
opncli netsnmp service status

