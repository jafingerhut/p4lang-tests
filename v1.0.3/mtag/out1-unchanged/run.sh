#! /bin/bash

OPTS=""

# To print details of how the minimum stage of each table access is
# determined.
OPTS="$OPTS --deps-debug-count-min-stages"

# To get detailed debug output of how table search key and result
# widths are calculated.
#OPTS="$OPTS --debug-key-result-widths"

# To skip calculation of transitive reduction of deps
#OPTS="$OPTS --deps-skip-transitive-reduction"

p4-graphs $OPTS ../mtag-edge.p4 > stdout.txt
