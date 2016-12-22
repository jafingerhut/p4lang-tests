#! /bin/bash

OPTS=""

# To only generate eps format files for graphs, instead of png.
#
# At least with Mac OS X Preview.app, it can search for text in the
# labels of the graph when the file is in eps format, but not for png,
# and for some strange reason not even for pdf.
#
# On Ubuntu 14.04 LTS Document View app, I could not successfully
# search for text labels with any of these formats.  Edit->Find was
# not even a selectable menu choice with eps files.  It was with pdf,
# but no matches were found, like with Preview.app.
#
# It is a little bit of a down side that Github does not render eps
# files graphically the way it does for pdf and png, but I prefer text
# searchability on my Mac for now.
OPTS="$OPTS --dot-format eps"

# To print details of how the minimum stage of each table access is
# determined.
OPTS="$OPTS --deps-debug-count-min-stages"

# To get detailed debug output of how table search key and result
# widths are calculated.
#OPTS="$OPTS --debug-key-result-widths"

# To skip calculation of transitive reduction of deps
#OPTS="$OPTS --deps-skip-transitive-reduction"

# Use new code for splitting match and action events for a table into
# two nodes, scheduled independently from each other.
#OPTS="$OPTS --split-match-action-events --deps-skip-transitive-reduction"

set -x
p4-graphs $OPTS ../mtag-edge.p4 > stdout.txt

# Also generate png format graphs from the same .dot files without
# rerunning p4-graphs.  Useful for linking to on Github with graphic
# rendering, which eps files do not give.
BASENAME="mtag-edge"
for CHART in parser tables ingress.tables_dep egress.tables_dep
do
    dot -Tpng ${BASENAME}.${CHART}.dot > ${BASENAME}.${CHART}.png
done
