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
  - create
  - remove
  - list
EOS

}

create()
{
    config_yml="config.yml"
    topkey="networks"

    num=$(cat ${config_yml} | yq -c ".${topkey} | length")

    cat $config_yml | yq -c ".${topkey}[]" |
        while read -r item; do
            name=$(echo "$item" | jq -r '.name // empty')
            parent=$(echo "$item" | jq -r '.parent // empty')
            driver=$(echo "$item" | jq -r '.driver // empty')
            subnet=$(echo "$item" | jq -r '.subnet // empty')
            gateway=$(echo "$item" | jq -r '.gateway // empty')
            cmd="docker network create"
            cmd="$cmd --driver=${driver}"
            cmd="$cmd --subnet=\"${subnet}\""
            if [ ! -z "$gateway" ]; then
              cmd="$cmd --gateway=\"${gateway}\""
            fi
            cmd="$cmd -o parent=${parent}"
            cmd="$cmd ${name}"
            echo "CMD: $cmd"
            $cmd
        done
}

remove()
{
    config_yml="config.yml"
    topkey="networks"

    num=$(cat ${config_yml} | yq -c ".${topkey} | length")

    cat $config_yml | yq -c ".${topkey}[]" |
        while read -r item; do
            name=$(echo "$item" | jq -r '.name // empty')
            cmd="docker network rm ${name}"
            echo "CMD: $cmd"
            $cmd
        done
}

list()
{
  docker network ls
}

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
  target=$(echo $target | tr '-' '_')
  num=`LANG=C type $target 2>&1 | grep 'function' | wc -l`
  if [ "$num" -ne 0 ]; then
    $target
  else
    #echo "ERROR : $arg is not shell function"
    #exit 1
    default $target
  fi
done

