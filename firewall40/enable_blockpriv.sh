#!/bin/sh

ssh -T firewall40 <<'EOF'
sed -i '' \
  's|<blockpriv>0</blockpriv>|<blockpriv>1</blockpriv>|' \
  /conf/config.xml

configctl filter reload
EOF

