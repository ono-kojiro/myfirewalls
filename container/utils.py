#!/usr/bin/env python3

import sys

import getopt
import json
import yaml

import re

import copy
import subprocess

import logging
logger = logging.getLogger(__name__)

from jinja2 import Environment, FileSystemLoader

from pprint import pprint

configs = None

def read_json(filepath) :
    fp = open(filepath, mode='r', encoding='utf-8')
    data = json.loads(fp.read())
    fp.close()
    return data

def read_yaml_list(filepath):
    fp = open(filepath, mode="r", encoding="utf-8")
    docs = yaml.load_all(fp, Loader=yaml.loader.SafeLoader)

    data = []
    for items in docs:
        for item in items:
            data.append(item)

    fp.close()
    return data

def read_yaml_list(filepath):
    fp = open(filepath, mode="r", encoding="utf-8")
    docs = yaml.load_all(fp, Loader=yaml.loader.SafeLoader)

    data = []
    for items in docs:
        for item in items:
            data.append(item)

    fp.close()
    return data

def read_yaml_dict(filepath):
    fp = open(filepath, mode="r", encoding="utf-8")
    docs = yaml.load_all(fp, Loader=yaml.loader.SafeLoader)
    
    data = {}
    for doc in docs:
        data = data | copy.deepcopy(doc)

    fp.close()
    return data

def load_config(config_yml):
    global configs
    configs = read_yaml_dict(config_yml)

def usage():
    print("Usage : {0}".format(sys.argv[0]))

def all():
    print('DEBUG: all')

def run_command_lines(cmd):
    proc = subprocess.Popen(
        cmd, shell=True, text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    for line in proc.stdout :
        yield line

    rc = proc.wait()

    if rc != 0:
        raise RuntimeError(
            f"command failed: {cmd}"
        )

def run_command(cmd):
    print(f"{cmd}")

    for line in run_command_lines(cmd):
        print(line, end='')
    
def create():
    cmd = 'docker compose up --no-start'
    run_command(cmd)

def start():
    cmd = 'docker compose start'
    run_command(cmd)

def stop():
    cmd = 'docker compose stop'
    run_command(cmd)

def down():
    cmd = 'docker compose down'
    run_command(cmd)

def compose():

    env = Environment(
        loader=FileSystemLoader("."),
        trim_blocks=True,
        lstrip_blocks=True,
    )

    template = env.get_template('docker-compose.yml.j2')

    ids = []
    for item in configs['terminals'] :
        ids.append(item['id'])

    data = {
        "terminals" : ids,
    }

    output = 'docker-compose.yml'
    fp = open(output, mode='w', encoding='utf-8')
    fp.write(template.render(**data))
    fp.write('\n')
    fp.close()

def vip_add():
    octs = [ '13', '41', '42', '43' ]
    for val in octs :
        term = 'terminal{0}'.format(val)
        addr = '192.168.{0}.2/24'.format(val)
        cmd = 'docker exec -i {0} ip addr add {1} dev eth0'.format(term, addr)
        run_command(cmd)

def vip_delete():
    octs = [ '13', '41', '42', '43' ]
    for val in octs :
        term = 'terminal{0}'.format(val)
        addr = '192.168.{0}.2/24'.format(val)
        cmd = 'docker exec -i {0} ip addr del {1} dev eth0'.format(term, addr)
        run_command(cmd)

def vip_list():
    octs = [ '13', '41', '42', '43' ]
    for val in octs :
        term = 'terminal{0}'.format(val)
        cmd = 'docker exec -i {0} ip addr show eth0'.format(term)
        run_command(cmd)

def main():
    ret = 0

    try:
        opts, args = getopt.getopt(
            sys.argv[1:],
            "hvo:c:",
            [
                "help",
                "version",
                "output=",
                "config=",
            ]
        )
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)
	
    output = None
    config_yml = 'config.yml'
	
    for o, a in opts:
        if o == "-v":
            usage()
            sys.exit(0)
        elif o in ("-h", "--help"):
            usage()
            sys.exit(0)
        elif o in ("-o", "--output"):
            output = a
        elif o in ("-c", "--config"):
            config_yml = a
        else:
            assert False, "unknown option"
	
    if output is not None :
        fp = open(output, mode='w', encoding='utf-8')
    else :
        fp = sys.stdout
	
    if ret != 0:
        sys.exit(1)
 
    if config_yml is not None :
        load_config(config_yml)

    for target in args:
        target = re.sub(r'-', '_', target)
        if target in globals():
            func = globals()[target]
            res = func()
        else :
            print('ERROR: no such function, {0}'.format(target),
                file=sys.stderr)
            sys.exit(1)
            #usage()

    if output is not None :
        fp.close()
	
if __name__ == "__main__":
	main()
