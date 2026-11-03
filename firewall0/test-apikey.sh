#!/bin/sh

. ./apikey.shrc
. ./config.shrc

url=https://$target/api/core/system/status
curl -s -u "$key:$secret" -k $url | jq .

