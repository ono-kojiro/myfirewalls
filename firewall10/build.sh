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

test_api()
{
  . ./apikey.shrc
  . ./config.shrc

  curl -s -k -u "$key:$secret" \
      https://$target/api/core/system/status | jq .
}

enable_snmp()
{
  netsnmp
  netsnmp_enable
  netsnmp_user
}

netsnmp()
{
  opncli core firmware install --pkg_name=os-net-snmp
  sleep 5
  opncli core firmware get
}

netsnmp_user()
{
  . ./config.shrc
  
  conffile=`pwd`/snmp/hosts/${target}.conf
  username=`cat $conffile | grep '^defSecurityName' | awk '{ print $2 }'`
  password=`cat $conffile | grep '^defAuthPassphrase' | awk '{ print $2 }'`
  enckey=`cat $conffile | grep '^defPrivPassphrase' | awk '{ print $2 }'`

  opncli netsnmp user add_user \
      username="$username" \
      password="$password" \
      enckey="$enckey" \
      enabled=1

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
  . ./config.shrc
  SNMPCONFPATH=`pwd`/snmp \
    snmpwalk $target SNMPv2-MIB::sysDescr
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
  num=`LANG=C type $target | grep 'function' | wc -l`
  if [ $num -ne 0 ]; then
    $target
  else
    #echo "ERROR : $target is not shell function"
    #exit 1
    default $target
  fi
done

