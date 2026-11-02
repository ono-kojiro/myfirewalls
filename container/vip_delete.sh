#!/bin/sh

oct3s="13 41 42 43"

for oct3 in $oct3s; do
  terminal="terminal$oct3"
  addr="192.168.$oct3.2/24"
  docker exec -it $terminal ip addr del $addr dev eth0
  docker exec -it $terminal ip addr show eth0
done

