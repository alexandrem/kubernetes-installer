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
    data = json.loads(objects['data'])
except:
    error(input)

results = {
    'yaml': yaml.dump(data, default_flow_style=False)
}

print(json.dumps(results))
