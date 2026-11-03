import sys

import logging
logger = logging.getLogger(__name__)

import json
import yaml

import copy

import subprocess

__all__ = [
  'read_json',
  'read_yaml_list',
  'read_yaml_dict',
  'run_command_lines',
  'run_command',
  'setup_logging',
]

def setup_logging(logfile=None, debug=False):
    root = logging.getLogger()
    level = logging.INFO
    
    # without timestamp
    if debug :
        fmt = logging.Formatter(
            "%(levelname)s %(name)s: %(message)s",
        )
    else :
        fmt = logging.Formatter(
            "%(message)s",
        )
    # with timestamp
    #fmt = logging.Formatter(
    #   "%(asctime)s %(levelname)s %(name)s: %(message)s",
    #   datefmt="%Y-%m-%dT%H:%M:%S%z",
    #)

    # Handler
    if logfile is None :
        handler = logging.StreamHandler(sys.stdout)
    else :
        handler = logging.FileHandler(logfile, mode='w')

    handler.setFormatter(fmt)
    root.handlers.clear()
    root.addHandler(handler)

    if debug :
        level = logging.DEBUG

    root.setLevel(level)

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

def read_yaml_dict(filepath):
    fp = open(filepath, mode="r", encoding="utf-8")
    docs = yaml.load_all(fp, Loader=yaml.loader.SafeLoader)
    
    data = {}
    for doc in docs:
        data = data | copy.deepcopy(doc)

    fp.close()
    return data

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

