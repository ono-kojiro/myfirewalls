#!/bin/sh

set -eu

opncli firewall filter search_rule > rules.json

categories="red blue"

for category in $categories; do
  echo "remove $category rules"
  cat rules.json \
    | jq --arg category "$category" '[
          .rows[] 
          | select(."%categories" == $category ) 
          | { uuid, categories: ."%categories" }
        ]' > target.json

  count=$(jq -r 'length' target.json)
  echo "target rules: $count"

  cat target.json | jq -r '.[].uuid' | \
    while read -r uuid
        do
            echo "remove uuid: $uuid"
            opncli firewall filter del_rule --uuid="$uuid"
        done
done

opncli firewall filter apply

