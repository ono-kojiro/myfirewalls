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

apikey()
{
  ansible-playbook $flags -i hosts.yml -t apikey site.yml
}

test_apikey()
{
  . ./.env

  url=$OPNSENSE_BASE_URL/api/core/system/status
  curl -s -u "$OPNSENSE_KEY:$OPNSENSE_SECRET" -k $url | jq .
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

