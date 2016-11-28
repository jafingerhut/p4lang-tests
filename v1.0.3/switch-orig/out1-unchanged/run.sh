#! /bin/bash

p4-graphs --deps-debug-count-min-stages --primitives ../primitives.json ../switch.p4 > stdout.txt
