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

from utils import *

configs = None
flags = ''

def load_config(config_yml):
    global configs
    logger.debug('read config, {0}'.format(config_yml))
    configs = read_yaml_dict(config_yml)

def usage():
    print('usage: {0} [OPTIONS] TARGET ...'.format(sys.argv[0]))

    msg = '''
  options:
    -h, --help               show help
    -v, --version            show version
    -d, --debug              enable debug
    -o, --output FILE        output file
    -l, --logfile FILE       logfile
'''

    print("{0}".format(msg))

def all():
    logger.info('all')

def hosts():
    cmd = f'ansible-inventory -i inventory.yml --list --yaml > hosts.yml'
    run_command(cmd)

def deploy():
    tag = 'deploy'
    cmd = f'ansible-playbook {flags} -i hosts.yml -t {tag} site.yml'
    run_command(cmd)

def apikey():
    tag = 'apikey'
    cmd = f'ansible-playbook {flags} -i hosts.yml -t {tag} site.yml'
    run_command(cmd)

def main():
    ret = 0

    try:
        opts, args = getopt.gnu_getopt(
            sys.argv[1:],
            "hvo:c:dl:",
            [
                "help",
                "version",
                "output=",
                "config=",
                "logfile=",
            ]
        )
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)
	
    output = None
    debug = False
    logfile = None
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
        elif o in ("-l", "--logfile"):
            logfile = a
        elif o in ("-d", "--debug"):
            debug = True
        else:
            assert False, "unknown option"

    if output is not None :
        fp = open(output, mode='w', encoding='utf-8')
    else :
        fp = sys.stdout
	
    if ret != 0:
        sys.exit(1)

    setup_logging(logfile, debug)
    logger.debug('Debug mode')
 
    if config_yml is not None :
        load_config(config_yml)

    for target in args:
        target = re.sub(r'-', '_', target)
        if target in globals():
            func = globals()[target]
            res = func()
        else :
            logger.error('no such function, {0}'.format(target))
            sys.exit(1)

    if output is not None :
        fp.close()
	
if __name__ == "__main__":
	main()
