#!/bin/sh

set -eu

opncli firewall filter search_rule > filters.json

cat filters.json

