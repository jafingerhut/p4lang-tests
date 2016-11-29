#! /bin/bash

OPTS="--deps-debug-count-min-stages"

# To get detailed debug output of how table search key and result
# widths are calculated.
#OPTS="--deps-debug-count-min-stages --debug-key-result-widths"

p4-graphs $OPTS --primitives ../primitives.json ../switch.p4 > stdout.txt
