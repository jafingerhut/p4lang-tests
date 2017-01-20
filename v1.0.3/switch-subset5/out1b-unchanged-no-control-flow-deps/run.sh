#! /bin/bash

p4-graphs --deps-no-control-flow-edges --deps-no-condition-labels --deps-no-fields-on-edges --primitives ../primitives.json ../switch.p4 > stdout.txt
