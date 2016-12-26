# Introduction

This repository includes sample P4 programs, publicly available, plus
commands used to analyze them, and the output files those commands
produce.

The section "Output files of `p4-graphs`" below contains some
documentation to aid in interpreting the output files of that program.


## Related repositories

* https://github.com/p4lang/p4-hlir and fork
      https://github.com/jafingerhut/p4-hlir - Python source code for
      `p4-validate` and `p4-graphs` programs that parse P4 source code
      and produce HLIR (High Level Intermediate Representation) of the
      program.  This is a collection of Python data structures
      representing things in the program like headers, tables,
      actions, conditional expressions, etc. plus dependencies and
      relationships between them.  My forked version has some
      additional command line options for `p4-graphs` that are used in
      this repository.

* https://github.com/p4lang/switch - source for switch.p4, copied into
      this repository in directory
      [v1.0.3/switch-orig/](v1.0.3/switch-orig/)


## Output files of `p4-graphs`

This command:

    p4-graphs <basename>.p4

produces several output files, if it successfully parses the input
file, and the p4 program passes several semantic checks:

* _Parse graph_ in files: `<basename>.parser.*`
* _Table control flow graph_ in files: `<basename>.tables.*`
* _Table dependency graphs_ in files:
  `<basename>.ingress.tables_dep.*` for ingress pipeline, and
  `<basename>.egress.tables_dep.*` for egress pipeline.

The `.dot` files are input files in the syntax expected by the `dot`
program in the [GraphViz](http://www.graphviz.org) package.  They are
used to generate the corresponding drawings of graphs in files in
formats like `.eps` or `.png`.

More details about each of these graphs is given below.



### Parse graph

Files: `<basename>.parser.*`

Command line option: --parser

Primary functions in `p4-graphs` that generates them:
`export_parse_graph` and `dump_parser` in file source file dot.py.

Small example for mtag-edge.p4:
[v1.0.3/mtag/out1-unchanged/mtag-edge.parser.png](v1.0.3/mtag/out1-unchanged/mtag-edge.parser.png)

Larger example for switch.p4:
[v1.0.3/switch-orig/out1-unchanged/switch.parser.png](v1.0.3/switch-orig/out1-unchanged/switch.parser.png)

Parse graphs give good detailed representations of the parser nodes
and the field values used to decide which parse node to go to next.
They contain nothing about tables or actions.  Each parse graph begins
with the packet arriving from the wire, and ends with the first table
access.

TBD: Give 'legend' explaining shapes, styles, and colors of nodes and
edges.

TBD: Link to example, calling out pieces of it and what they mean.



### Table control flow graph

Files: `<basename>.tables.*`

Command line option: --table

Primary functions in `p4-graphs` that generates them:
`export_table_graph` and `dump_table`

Small example for mtag-edge.p4:
[v1.0.3/mtag/out1-unchanged/mtag-edge.tables.png](v1.0.3/mtag/out1-unchanged/mtag-edge.tables.png)

Larger example for switch.p4:
[v1.0.3/switch-orig/out1-unchanged/switch.tables.png](v1.0.3/switch-orig/out1-unchanged/switch.tables.png)

I believe the main point of these graphs is to graphically show the
control flow of apply(table) occurrences in the P4 program, relative
to 'if' conditions, with 'then'/'else' branches of the 'if' condition
explicitly represented.  TBD whether this description is missing any
details, which I may not get to soon, since the table dependency
graphs are more useful for my current purposes.

All sequential dependencies between apply(table) actions are also
shown (e.g. apply(T1) is before apply(T2) sequentially means a
directed edge from T1 to T2 in this graph).  All possible action names
for tables are also shown explicitly below each table, branching out
beneath the table, since the semantics are that exactly one of those
actions will be performed as a result of the apply(table).

There is nothing in this graph to represent any other dependencies
between tables, e.g. the MATCH, ACTION, SUCCESSOR,
etc. dependendencies that appear in the table dependency graph (see
below).

Table control flow graphs have these elements in them, from looking at
the output of p4-v1.0.3/mtag-edge.p4 and comparing it to the source
code.

Legend:

* double-circled node - Used for special nodes 'buffer', representing
    buffering point at end of ingress pipeline, just before egress
    pipeline, and for node 'egress' at end of egress pipeline.  My
    guess is that it is probably not used for any other nodes in this
    graph.

* ellipse node - Used for tables.  Table nodes have one solid arrowed
    edge leading out of it for each possible action of the table,
    labeled with the name of the action.

* rectangle node - Used for conditional expressions in an 'if'
    statement.  The box contains the conditional expression.  Leading
    out of the node are two solid lines.  The one ending with a circle
    filled in black is the 'true' / 'then' branch.  The one ending
    with a circle filled in white is the 'false' / 'else' branch.



### Table dependency graph

Files: `<basename>.ingress.tables_dep.*` for ingress pipeline, and
`<basename>.egress.tables_dep.*` for egress pipeline.  Also a table of
schedule accesses obeying the dependencies in the p4 program, and
requiring the fewest number of stages possible, is given in the
standard output.

Command line option: --deps

Additional command line options in my forked version of `p4-graphs`
that customize how table dependency graphs are drawn (see output of
`p4-graphs -h` for more details): `--deps-no-control-flow-edges`
`--deps-no-condition-labels` `--deps-no-fields-on-edges`.

Primary functions in `p4-graphs` that generates them:
`export_table_dependency_graph` in file dot.py, and
`build_table_graph_ingress`, `build_table_graph_egress`, and
`generate_graph` in file dependency_graph.py.

Small examples for mtag-edge.p4:
* ingress [v1.0.3/mtag/out1-unchanged/mtag-edge.ingress.tables_dep.png](v1.0.3/mtag/out1-unchanged/mtag-edge.ingress.tables_dep.png)
* egress [v1.0.3/mtag/out1-unchanged/mtag-edge.egress.tables_dep.png](v1.0.3/mtag/out1-unchanged/mtag-edge.egress.tables_dep.png)

Larger examples for switch.p4:
* ingress [v1.0.3/switch-orig/out1-unchanged/switch.ingress.tables_dep.png](v1.0.3/switch-orig/out1-unchanged/switch.ingress.tables_dep.png)
* egress [v1.0.3/switch-orig/out1-unchanged/switch.egress.tables_dep.png](v1.0.3/switch-orig/out1-unchanged/switch.egress.tables_dep.png)

The same switch.p4 source code as the previous examples, but with many
details omitted, to make the graphs smaller (no control flow edges, no
labels on edges, no code of conditions in condition nodes):
* ingress [v1.0.3/switch-orig/out2-unchanged-p4-smaller-dep-graphs/switch.ingress.tables_dep.png](v1.0.3/switch-orig/out2-unchanged-p4-smaller-dep-graphs/switch.ingress.tables_dep.png)
* egress [v1.0.3/switch-orig/out2-unchanged-p4-smaller-dep-graphs/switch.egress.tables_dep.png](v1.0.3/switch-orig/out2-unchanged-p4-smaller-dep-graphs/switch.egress.tables_dep.png)

Legend for nodes:

* ellipse - table node, corresponding with a single 'table' definition
  in the source code.  With recent versions of p4-hlir, a table can
  appear more than once in a graph if it is apply'ed in disjoint
  conditional branches.  See
  [v1.0.3/table-twice-exclusive/README.md](v1.0.3/table-twice-exclusive/README.md).
* rectangle - condition node, most likely always corresponding with a
  single 'if' statement's condition in the source code.

Legend for edges:

Edges represent dependencies between nodes.  They are listed below
from 'most restrictive' to 'least restrictive', meaning the
restrictions that the dependency makes about when the two actions can
be scheduled relative to one another.

Short version just to get the color and dependency type
correspondence:

* `MATCH` `red` - most restrictive
* `ACTION` `blue`
* `SUCCESSOR` `green`
* `REVERSE_READ` `orange` (or `yellow`)
* `CONTROL_FLOW` `dotted black` - least restrictive

Longer version with more details.  In all cases, if there is a label
on the edge, it is a list of packet fields that are the ones that
cause the dependency to exist.

* `MATCH` dependency, drawn as red solid line with arrow, and label.
  Can only be from a table, but to either a table or a condition.
  Represents at least one action of 'from' table writing a field that
  'to' condition reads, or that 'to' table uses in its table search
  key.  The action represented by the 'to' node cannot begin until the
  'from' table action is completely finished.

* `ACTION` dependency, drawn as blue solid line with arrow.  Can only
  be from a table, to a table.  Represents at least one action of
  'from' table writing a field that 'to' table action reads or writes,
  but 'to' table does _not_ use the field in its search key.  The
  table search represented by the 'to' node can begin before the
  'from' table action completes, but the 'to' table action needs to
  wait until 'from' table action completes, if it is W->R action
  dependency.  If it is W->W action dependency (there are at least
  some examples of this in switch.p4, e.g. table 'ip_acl' to
  'ipv4_racl' and 'ipv6_racl', and also to those two tables from
  'ipv6_acl' and 'mac_acl'), then 'to' table action just needs to have
  its writes occur after 'from' table action writes.

* `SUCCESSOR` dependency, drawn as green solid line with filled in
  circle, no label.  Occurs when a 'from' table does an
  apply(to_table) conditionally, based on the action of the result, or
  the hit/miss part of the result.  Also occurs from a condition or
  table, to a condition or table, I believe to indicate the sequential
  order of those two things (TBD whether there is more to it than
  this).

* `REVERSE_READ` dependency, drawn as yellow (or orange) solid line,
  and label.  This occurs from a table that reads a field, or from a
  condition that reads a field, to a table that has an action that
  writes the field.  In the RMT hardware architecture, it is
  straightforward to schedule these in the same stage, but the reason
  for the dependency is to ensure that the 'from' table/condition is
  _not executed after_ the 'to' table action writes.

* `CONTROL_FLOW` dependency, drawn as black dotted line with arrow, no
  label (dependency is in quotes because such dependencies make no
  restrictions on scheduling -- we are free to reorder two events
  during exection if none of the other dependencies above apply
  between two nodes).

References in the code:

For each table, its dependencies are iterated through in function
`generate_graph` via the method `dependencies_for`.  When edges to be
added to the table dependency graph are constructed in the `__init__`
method of class `Edge`, the `type_` attribute of the `Edge` object is
set to one of the following:

* red line - `MATCH` if the dependency object inherits from class
  `MatchDep`.  A `MatchDep` dependency indicates that the 'from' table
  has an action that writes a field of the packet, and the 'to' node
  is either a table that uses the field in its search key, or a
  condition node that reads the field.  See function
  `is_match_dependency`.

* blue line - `ACTION` if the dependency object inherits from class
  `ActionDep`.  An `ActionDep` is a dependency that is not a
  `MatchDep`, but the 'from' table has an action that writes a field,
  and the 'to' node is a table that accesses the field, either reading
  or writing it (TBD if there is an existing example of that 'to' node
  also writing the field in its action).  See function
  `is_action_dependency`.

* green line - `SUCCESSOR` if the dependency object inherits from
  class `SuccessorDep`.  TBD English description.  See functions
  `is_successor_dependency` and `is_predication_dependency`.

* yellow or orange line - `REVERSE_READ` if the dependency object
  inherits from class `ReverseReadDep`.  See function
  `is_reverse_read_dependency`.  (I made my own modification to
  p4-hlir to change color to orange, for better contrast against white
  background.)

* dotted line - `CONTROL_FLOW` if the table is _not_ returned by
  `dependencies_for` method, but is in the `next_` collection for the
  table (not sure what that is yet).



TBD: Note that some 'tables' in a p4 program can have no 'reads'
block, and thus no search key.  Such a table is only there for the
actions it can perform.  switch.p4's table switch_config_params is one
example of this.  It would be nice to include in the graph table node
labels a string like "key 57", where the number is the total number of
bits in all fields in the 'reads' statement, if the table has one, or
0 if it does not.  It would also be nice to indicate the number of
bits in the table's result with a string like "result 10".

TBD: There are functions generate_dot in two different source files of
p4-hlir, with many similarities, but not identical.  Files:

* Version used by p4-graphs program:
  p4_hlir/graphs/dependency_graph.py
* Version not used by p4-graphs program:
  p4_hlir/hlir/table_dependency.py

Why?  Is one obsolete?  Should one be eliminated in favor of the
other?

TBD: I found there is a function `transitive_reduction` in the HLIR
code, to reduce the number of dependencies to a smaller set (perhaps a
minimal set?).  It _is_ used when p4-graphs is run, via this call flow
through the p4-graphs code:

* h = HLIR(args.source)  (HLIR is p4_hlir.main.HLIR)
* h.build(), which calls:
* p4.p4_dependencies() in file p4_hlir/hlir/p4.py, which calls:
* dep.annotate_hlir() in file p4_hlir/hlir/table_dependency.py, which
  calls:
* transitive_reduction() in that same file, for both ingress_graph and
  egress_graph

My forked version of `p4-graphs` adds a new command line option
`--deps-skip-transitive-reduction` that skips this step, since it has
been found to take a long time for some larger P4 programs.  Skipping
that step can cause `dot` to take too long to generate drawings of the
dependency graphs, so I also added the option `--dot-format none` to
skip running `dot`.  The `.dot` text files will still be generated.

TBD: It seems like it should be possible to do this in linear or
quadratic time rather than the O(N^3) claimed in the source code
comments, because the dependency graph must be a DAG.  The existing
`transitive_reduction` code takes different types of dependency edges
into account, though, so not sure how to preserve that behavior even
if there is a faster algorithm for 'normal graphs' with only one type
of edge.

TBD: The table dependency graphs currently always show
`SuccessorDep`'s with a circle at the 'to' end of the line, indicating
a True branch for the condition.  This is often incorrect.  The
function generate_dot in file dependency_graph.py is probably using
the wrong condition to determine whether to draw the arrowhead as a
dot or a diamond using the value edge.dep.value, or perhaps
edge.dep.value is not initialized correctly when creating the data
structure from which the graph is drawn.  It would be nice to correct
that.



# Other stuff that might be useful to incorporate above some time

These things may be useful to incorporate in the main text above some
time, but for now I am treating it as kind of a 'dumping ground' of
things that I will likely end up deleting, to keep the text above a
bit shorter.


## Table control flow graph extra stuff

Nodes with ellipses around them include the following, and correspond
1 for 1 with 'table' definition in the .p4 source code, with the same
names:

    strip_mtag
    identify_port
    local_switching
    mTag_table
    egress_check
    egress_meter
    meter_policy

Each of those nodes has one or more lines with arrowheads leading
downwards out of them.  Each is labeled with the name of one of the
actions defined for the table.  Often the destinations of these arrows
are the same next node, but they can differ.  The one example I have
seen of them differing so far is for the table 'egress_meter', where
the arrowed line labeled 'hit' goes to the table 'meter_policy', but
the arrowed line labeled 'miss' skips that table and goes to the
'egress' node.

NOTE: In the standard output of the p4-graphs command for input file
mtag-edge.p4, it shows the following:

    parsing successful
    semantic checking successful
    Header type standard_metadata_t not byte-aligned, adding padding
    Generating files in directory /home/andy/p4/andy-tests/mtag-v1.0.2
    
    TABLE DEPENDENCIES...
    
    INGRESS PIPELINE
    ['strip_mtag', 'identify_port']
    ['local_switching']
    ['mTag_table']
    pipeline ingress requires at least 3 stages
    
    EGRESS PIPELINE
    ['egress_check', 'egress_meter']
    ['meter_policy']
    pipeline egress requires at least 2 stages

I am not sure yet how to interpret the output after the 'INGRESS
PIPELINE' line.

It could be that it is indicating that tables 'strip_mtag' and
'identify_port' can be searched concurrently, because even though the
'apply' operation for table 'identify_port' is sequentially after the
one for 'strip_mtag' in the p4 source code, the search key for
'identify_port' does not depend upon the actions of table
'strip_mtag'.

The search key for table identify_port contains only
standard_metadata.ingress_port.  That field is used several times in
the source code, but only to read it, never to modify it.

As an experiment, I added a field to table identify_port's search key
that is modified by an action of table strip_mtag, field
local_metadat.mtagged.  The standard output changed to the below:

    parsing successful
    semantic checking successful
    Header type standard_metadata_t not byte-aligned, adding padding
    Generating files in directory /home/andy/p4/andy-tests/mtag-v1.0.2
    
    TABLE DEPENDENCIES...
    
    INGRESS PIPELINE
    ['strip_mtag']
    ['identify_port']
    ['local_switching']
    ['mTag_table']
    pipeline ingress requires at least 4 stages
    
    EGRESS PIPELINE
    ['egress_check', 'egress_meter']
    ['meter_policy']
    pipeline egress requires at least 2 stages

That is a pretty strong indication that my guess above is correct
about dependencies.

local_switching search key does depend upon action of identify_port,
because action 'common_set_port_type' of table 'identify_port'
modifies field 'local_metadata.ingress_error', which is used in
'control ingress' in an 'if' condition to decide whether to do any
further table searches.

That field cannot be modified by actions of table 'strip_mtag', but
'strip_mtag' is sequentially before the if condition, and its actions
must be done before finishing ingress pipeline, so may as well do it
before the if condition is evaluated and then/else branches selected.

There is an 'if' checking value of field
'standard_metadata.egress_spec' after table local_switching is
applied, and that field can be modified by one of that table's
actions, so mTag_table access is dependent upon result of table
local_switching.

Table 'egress_meter' is applied in the egress pipeline sequentially
after table 'egress_check', but the search key of 'egress_meter'
cannot be modified by the actions of 'egress_check' (I verified this
by reading through the code).  Thus it makes sense that they would
show up in standard output as possibly concurrent.

Table 'meter_policy' access depends upon hit/miss result of table
'egress_meter', so is dependent upon it.  From examining the graph
`<basename>.egress.tables_dep.png`, it shows that the key of table
meter_policy includes field local_metadata.color, which is modified by
an action of table egress_meter.



## Table dependency graph extra stuff

======================================================================

Possible kinds of dependencies I can think of right now, which I hope
includes everything, but I may be missing something.

A single node (an apply(table), or conditional expression evaluation
of an 'if' statement) might do these things with a single field:

* table node that:
  * reads field to create search key
  * reads field in action
  * writes field in action
  * any subset of the above 3 possibilities
* condition node that reads field to evaluate the condition

Let N1 and N2 be two nodes, where in the P4 source code N1 is executed
sequentially before N2, and let F be the set of fields that they both
access.

If N1 and N2 only read the fields in F, then there need not be any
dependency between them.  They can be executed in an arbitrary order,
and the effects will be the same.

If there is a field that N1 writes and N2 reads, then clearly N1's
write should finish before N2's read starts.  If N2's read is for
constructing a table search key, then the search cannot be initiated
until N1's write completes.  This is called a `MatchDep` in HLIR
source code, and p4-graphs indicates it with a red line.

See function `is_match_dependency` for details of how the code
determines whether the dependency is a `MatchDep`.

In function `count_min_stages`, if N1 to N2 is a `MatchDep`, then N2
must be in a stage at least 1 more than N1.  That makes sense in a
hardware architecture where all writes are done at the end of a stage,
and all reads at the beginning.

Examples:

* switch.p4 table ingress_port_mapping to table port_vlan_mapping,
  because ingress_port_mapping's only action modifies field
  ingress_metadata.ifindex, and port_vlan_mapping's search key
  includes that field.
* switch.p4 table ingress_port_mapping to condition "_condition_20
  (ingress_metadata.port_type == 0)", because ingress_port_mapping's
  only action modifies field ingress_metadata.port_type, and the
  condition reads that field.

However, if all of N2's reads of N1's writes are in N2's table action,
then N2's table search could be started _before_ N1's writes complete,
as long as N2's _actions_ do not start until after N1's writes
complete.  This is called an `ActionDep` in HLIR source code, and
p4-graphs indicates it with a blue line.

See function `is_action_dependency` for details.

In function `count_min_stages`, if N1 to N2 is an `ActionDep`, then N2
must be in a stage at least 1 more than N1.  That makes sense in a
hardware architecture where all writes are done at the end of a stage,
and all reads at the beginning.

Examples:

* switch.p4 table ingress_port_mapping to table switch_config_params,
  because ingress_port_mapping's only action modifies field
  ingress_metadata.ifindex, and table switch_config_param's only
  action reads that field.  None of switch_config_param's search key
  fields are modified by ingress_port_mapping's action, otherwise this
  would be a `MatchDep` instead.

If N1 reads a field that N2 writes, then executing N2's write before
N1's read would in general change the behavior of N1, and make it
behave in a way that violates the sequential execution of N1 followed
by N2.  This is similar to a `MatchDep`, in that N2's writes can only
be in its actions, so the launching of a table search for N2 can be
started before N1's reads complete.  This is called a `ReverseReadDep`
in HLIR source code.

See function `is_reverse_read_dependency` for details.

In function `count_min_stages`, if N1 to N2 is a `ReverseReadDep`,
then N2 may be in later stage as N1, _or the same stage as N1_.  That
makes sense in a hardware architecture where all writes are done
simultaneously at the end of a stage, and all reads simultaneously at
the beginning.

Examples:

* switch.p4 table validate_outer_ethernet to table
  fabric_ingress_dst_lkp, because the validate_outer_ethernet reads
  field ethernet.etherType in at least one action, and table
  fabric_ingress_dst_lkp's action terminate_cpu_packet writes that
  field.

If fields in F are only written, then N2's writes should be after N1's
writes, to preserve the effects of sequential execution.  Reads can be
done in any order.  TBD: Is there a name for this kind of dependency
in HLIR source code?


Another case that doesn't quite fit into the list of possibilities
above is called a `SuccessorDep` in the HLIR source code.

Examples:

* switch.p4 table ipv4_src_vtep to table ipv4_dest_vtep, which has a
  'conditional barrier' between them because the control block
  process_ipv4_vtep that apply's table ipv4_src_vtep only does apply
  on ipv4_dest_vtep if the result from table ipv4_src_vtep was action
  src_vtep_hit.  True return from function `is_predication_dependency`
  because the conditional barrier cb[1] is of class p4_action, where
  the action is src_vtep_hit.

* Another similar example: switch.p4 table nat_src to nat_flow,
  because apply on nat_flow is only done if result of nat_src lookup
  is action on_miss.

* Different reason for a `SuccessorDep` is from table
  validate_outer_ethernet to _condition_0 with description "(valid
  ipv4)".  This case also returns true from
  `is_predication_dependency` but this time because the conditional
  barrier cb[1] is of class tuple.  I am not sure why, but the tuple
  appears to contain one element for each action of table
  validate_outer_ethernet.  The condition '(valid ipv4)' appears to
  come from the line of code "if (valid(ipv4)) {" in control block
  process_validate_outer_header, which first does apply on
  validate_outer_ethernet, and only if the action is not
  malformed_outer_ethernet_packet does it evaluate that if statement.

* Different reason for a `SuccessorDep` is from _condition_33 with
  description "(((ingress_metadata.bypass_lookups & 2) == 0) and
  (multicast_metadata.ipv4_multicast_enabled == 1))" to table
  ipv4_multicast_route.  This causes function
  `is_successor_dependency` in the HLIR source code to return true.
  The condition comes from an if condition in control block
  process_ipv4_multicast, and the apply on table ipv4_multicast_route
  is only done if that condition is true.

* Another that causes `is_successor_dependency` to return true is from
  _condition_0 with description "(valid ipv4)" to _condition_1 with
  description "(valid ipv6)".  This comes from control block
  process_validate_outer_header, where _condition_0 is from the line
  "if (valid(ipv4)) {" and _condition_1 is from the line "if (valid
  (ipv6)) {".

TBD: Function `count_min_stages` allows scheduling of two table
accesses for tables T1 and T2 in the same stage even if there is a
conditional operation `SuccessorDep` dependency between them, from T1
to T2.

It seems perfectly OK to me to do such table accesses simultaneously
as long as there are no side effects from launching the table access
on T2, but what if there are?  What if T2 has a set of per-entry stats
associated with it directly, that should count number of times each
entry of T2 was matched?  Either the counter update needs to be done
after that stage, e.g. after the condition can be correctly evaluated,
or else you will update the stats when T2 is searched, making at least
the stats update behavior different than the sequential execution of
the P4 program would give.

"Almost example" from switch.p4: control block process_ipv4_urpf looks
up a table with apply(ipv4_urpf), and only if the result is type
on_miss does it apply(ipv4_urpf_lpm).  There are no statistics
associated with ipv4_urpf_lpm, so I see no issue with scheduling them
at the same time.  I suppose I could try a small modification to the
switch.p4 code that had stats on ipv4_urpf_lpm to see if it caused it
to be scheduled in a separate stage, but my guess is that as the
p4-graphs code is written, it would not.

======================================================================
