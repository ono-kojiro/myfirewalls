#!/bin/sh

opncli firewall alias del_item --name=host_ldapserver
opncli firewall alias del_item --name=port_1234

opncli firewall alias reconfigure

