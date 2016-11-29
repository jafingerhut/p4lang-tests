This output was produced by running this command:

    p4-graphs --primitives ../primitives.json ../switch.p4 > stdout.txt


To load switch.p4 HLIR in an interactive Python session:

% python

import p4_hlir
from p4_hlir.main import HLIR
import json
h=HLIR('../switch.p4')
with open('../primitives.json','r') as fp:
    h.add_primitives(json.load(fp))
h.build()
root=h.p4_ingress_ptr.keys()[0]

>>> root
p4_table.ingress_port_mapping

import pprint as pp
pp.pprint(dir(root))

pp.pprint(root.dependencies_for)
This is a dict with keys that are condition and table objects, with types:
    p4_hlir.hlir.p4_tables.p4_conditional_node
    p4_hlir.hlir.p4_tables.p4_table
The corresponding values are dependency objects, with types like:
    p4_hlir.hlir.dependencies.MatchDep
    p4_hlir.hlir.dependencies.ActionDep
    and others, I am sure

>>> root.match_fields
[(<p4_hlir.hlir.p4_headers.p4_field object at 0x7f55578ed3d0>, P4_MATCH_EXACT, None)]

Get a list of table names and their number of match fields:

ts = h.p4_tables.values()
tsm=map(lambda t: [len(t.match_fields), t], ts)
