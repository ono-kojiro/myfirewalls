#!/bin/sh

domain="Firewall10"

target="/var/lib/libvirt/images/${domain}.qcow2"

xmlfile="${domain}.xml"

tmpfile=`mktemp --suffix .xml`

virsh dumpxml $domain | tee ${tmpfile}

disk=`virsh dumpxml $domain \
  | xpath -q -e "/domain/devices/disk/source/@file" \
  | sed 's/ file=//; s/"//g'`

echo "detect disk, $disk"

sudo qemu-img info "$disk" | tee img_info.log

sudo qemu-img convert -O qcow2 "$disk" "$target"

cat $tmpfile | sed -e "s|$disk|$target|" | tee $xmlfile

