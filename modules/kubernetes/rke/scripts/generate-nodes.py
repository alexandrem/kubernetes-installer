#!/bin/env python

import json
import os
import sys
import yaml

def debug(obj):
    with open('debug.txt', 'w+') as f:
        f.write(str(obj))

def error(obj):
    print("invalid input string: %v", obj)
    sys.exit(1)

input = sys.stdin

try:
    objects = json.load(input)
    nodes = json.loads(objects['nodes'])
except:
    error(input)

# debug(nodes)

# transform some inputs
# terraform null_data_source only allows string values, so we change the type
# before dumping the final yaml
for node in nodes:
    # defaults
    if not 'role' in node:
        node['role'] = ''
    if not 'labels' in node:
        node['labels'] = ''

    # make list from role
    if type(node['role']) is str:
        node['role'] = node['role'].split(',')
    # make map from labels string
    if type(node['labels']) is str:
        node['labels'] = dict(label.split('=') for label in node['labels'].split(',') if label)

nodes_wrapper = {
    'nodes': nodes
}

# debug(nodes_wrapper)

results = {
    'rke_template_nodes': yaml.dump(nodes_wrapper)
}

print(json.dumps(results))
