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

def usage():
    print("Usage : {0}".format(sys.argv[0]))

def all(configs):
    print('DEBUG: all')

def run_command_and_read_response(cmd):
    try :
        proc = subprocess.Popen(
                cmd,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
            )

        while True:
            line = proc.stdout.readline()
            if line:
                yield line.decode('utf-8', errors='replace')

            if not line and proc.poll() is not None:
                break

    except Exception as e:
        print("ERROR: subprocess.Popen failed", file=sys.stderr)
        print("ERROR: {0}".format(e), file=sys.stderr)
        sys.exit(1)

def run_command(cmd):
    for line in run_command_and_read_response(cmd):
        print(line, end='')
    
def create(configs):
    cmd = 'docker compose up --no-start'
    run_command(cmd)

def start(configs):
    cmd = 'docker compose start'
    run_command(cmd)

def stop(configs):
    cmd = 'docker compose stop'
    run_command(cmd)

def down(configs):
    cmd = 'docker compose down'
    run_command(cmd)

def compose(configs):

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
 
    configs = {}

    if config_yml is not None :
        configs = read_yaml_dict(config_yml)

    #pprint(configs)

    for target in args:
        target = re.sub(r'-', '_', target)
        if target in globals():
            func = globals()[target]
            res = func(configs)
        else :
            print('ERROR: no such function, {0}'.format(target),
                file=sys.stderr)
            sys.exit(1)
            #usage()

    if output is not None :
        fp.close()
	
if __name__ == "__main__":
	main()
