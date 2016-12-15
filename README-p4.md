# Introduction

Very brief summary of the kinds of relationships between things in P4
source code.


## Parser

When parsing is done, control passes to a user-specified `control`
block.  There can be more than one different `control` block that is
the first one to be called when parsing is complete, from different
parse nodes.


## Control block

Control blocks have no parameters.  All data about the packet
available to a control block is from the global headers and metadata
about the packet.

Control blocks can include 0 or more of the following things,
specifying sequential execution behavior:

* `apply` table calls
* `apply` and select table calls, with conditional execution of nested
  (unnamed) control blocks based upon the type of action, or the
  hit/miss result of the table search.
* `if` statements, with nested (unnamed) control blocks for then and
  else branches (else is optional)
  based upon true/false evaluation of the condition.
* Calls to other control blocks (no recursion permitted)

Control blocks cannot have loops.

No calls to `action`s are allowed directly inside a control block, but
one may work around that restriction by creating a table with an empty
search key and a single user-defined action.

`if` conditions can be arbitrarily complex boolean expressions with
`and`/`or`/`not`, arithmetic, and comparison operators.  `if`
statements can be daisy-chained with `else if`, or nested arbitrarily.

From P4 spec v1.0.3, Section 12 "Packet Processing and Control Flow":
"If the same table is invoked in multiple places from the control
flow, those invocations all refer to the same table instance; that is,
there is only one set of statistics, counters, meters, and
match+action entries for the table.  Targets may impose limitations on
these table invocations such as disallowing recursion, only allowing
tables to be referenced once, or only allowing control flow functions
to be referenced once."

TBD: Which of any of these restrictions does Barefoot compiler impose?

No recursion seems necessary for their HW arch.

Only allowing tables to be referenced once is ambiguous.  Does it mean:

* each table is only referenced once per packet, but it can be
  referenced in multiple mutually exclusive branches of execution?
* each table is only referenced once, regardless of whether the flows
  of execution are mutually exclusive?

Only allowing control flow functions to be referenced once seems like
an odd restriction to me, although if the main 'useful work' a control
block can do is by applying tables, then perhaps this restriction
would be a consequence of a table only being invoked once.


## Action definitions

They have 0 or more parameters, and can contain 0 or more calls to
other actions, either user-defined or primitive.  Recursion is not
permitted.

No `if` statements are permitted in user-defined action definitions
(they might be used inside the definitions of primitive actions, but
those definitions are outside of P4 language).

Standard primitive actions defined in Section 9.1 "Primitive Actions"
of P4 spec v1.0.3

Action blocks are only ever executed as a result of doing `apply` on a
table that has that action as one of its defined actions.  It could
also be executed because a table's action in turn calls another
action, and so on in the action block call tree.


## Primitive action categorization

Note that all of these can be made conditional by being included in an
action that is performed conditionally, for the reasons mentioned in
the control block section above.

(mod_header_seq) Always modifies the packet's parsed representation:

* `add_header`, `remove_header`, `push`, `pop`

(copy_bits) Modifies the packet's parsed representation, or metadata,
depending upon the action's operands, but with no arithmetic required,
merely copying of bits:

* `copy_header`, `modify_field`

(alu_bits) Same as previous, except also requires arithmetic to
calculate the value to be written:

* `add_to_field`, `add`, `subtract_from_field`, `subtract`, `bit_and`,
  `bit_or`, `bit_xor`, `shift_left`, `shift_right`,
  `modify_field_with_hash_based_offset`, `modify_field_rng_uniform`

(special_packet_mod)

* `truncate`, `drop`


TBD:

 40 (mod_header_seq)          add_header
 62 (copy_bits)               copy_header
168 (mod_header_seq)          remove_header
891 (copy_bits)               modify_field
 17 (alu_bits)                add_to_field (several with negative values)
 22 (alu_bits)                add
  0 (alu_bits)                subtract_from_field
  6 (alu_bits)                subtract
  6 (alu_bits)                modify_field_with_hash_based_offset
  1 (alu_bits)                modify_field_rng_uniform
  0 (alu_bits)                bit_and
  6 (alu_bits)                bit_or
 19 (alu_bits)                bit_xor
  3 (alu_bits)                shift_left
  0 (alu_bits)                shift_right
  0                           truncate
 11                           drop
  0                           no_op
  6 (mod_header_seq)          push
  0 (mod_header_seq)          pop
  4 (table_rmw_no_read_ret)   count
  2 (table_rmw_with_read_ret) execute_meter
  0 (table_read)              register_read
  0 (table_write)             register_write
  1                           generate_digest (used in switch.p4 for MAC learning)
  0 (special_ingress_only)    resubmit
  0 (special_egress_only)     recirculate
  0 clone_ingress_pkt_to_ingress / clone_i2i
  0 clone_egress_pkt_to_ingress / clone_e2i
  5 clone_ingress_pkt_to_egress / clone_i2e
  2 clone_egress_pkt_to_egress / clone_e2e
