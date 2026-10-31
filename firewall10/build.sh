#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

flags=""

help()
{
  usage
}

usage()
{
  cat << EOS
usage : $0 [options] target1 target2 ...

target:
  deploy
EOS

}

all()
{
  deploy
}

hosts()
{
  ansible-inventory -i inventory.yml --list --yaml > hosts.yml
}

deploy()
{
   ansible-playbook $flags -i hosts.yml site.yml
}

default()
{
  tag=$1
  ansible-playbook $flags -i hosts.yml -t $tag site.yml
}

snmp_enable()
{
  netsnmp
  netsnmp_user
  netsnmp_enable
}

netsnmp()
{
  opncli core firmware install --pkg_name=os-net-snmp
  sleep 5
  opncli core firmware get
}

netsnmp_user()
{
  opncli netsnmp user add_user username=myuser password=myauthpass enckey=myprivpass enabled=1
  opncli netsnmp service reconfigure
}

netsnmp_enable()
{
  opncli netsnmp general set enabled=1
  opncli netsnmp service reconfigure
}

snmp_start()
{
  opncli netsnmp service restart
}

snmp_status()
{
  opncli netsnmp service status
}

snmp_stop()
{
  opncli netsnmp service stop
}

test_snmp()
{
  echo hoge
  snmpwalk \
    -OX \
    -Pe \
    --hexOutputLength=0 \
    -m ALL \
    -M /usr/share/snmp/mibs \
    -v 3 \
    -l authPriv \
    -a SHA \
    -A myauthpass \
    -u myuser \
    -x AES \
    -X myprivpass \
    192.168.122.10 SNMPv2-MIB::sysDescr

  echo "snmpwalk finished"
}

hosts

args=""
while [ "$#" -ne 0 ]; do
  case $1 in
    -h )
      usage
      exit 1
      ;;
    -v )
      verbose=1
      ;;
	-* )
	  flags="$flags $1"
	  ;;
    * )
      args="$args $1"
      ;;
  esac
  
  shift
done

if [ -z "$args" ]; then
  help
  exit 1
fi

for target in $args; do
  target=`echo $target | tr '-' '_'`
  echo target is $target
  num=`LANG=C type $target | grep 'function' | wc -l`
  if [ $num -ne 0 ]; then
    $target
  else
    #echo "ERROR : $target is not shell function"
    #exit 1
    default $target
  fi
done

