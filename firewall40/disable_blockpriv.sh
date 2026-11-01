#!/bin/sh

ssh -T firewall40 <<'EOF'
sed -i '' \
  's|<blockpriv>1</blockpriv>|<blockpriv>0</blockpriv>|' \
  /conf/config.xml

configctl filter reload
EOF

