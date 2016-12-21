This source code was copied from this Github repository, directory `p4src`:

    https://github.com/p4lang/switch

Here is the version of the commit that I copied it from:

    commit cabf7e9d8fabf96846f6d34180e65af33bb87d39
    Author: srikrishnagopu <krishna@barefootnetworks.com>
    Date:   Wed Nov 2 11:01:55 2016 -0700

I found a mention of the primitive shift_left in this message sent to
the p4-dev email list:

    http://lists.p4.org/pipermail/p4-dev_lists.p4.org/2016-October/000513.html

It recommended copying this file

    https://github.com/p4lang/p4c-bm/blob/master/p4c_bm/primitives.json

and then running the p4-graphs command with these extra options:

    p4-graphs --primitives primitives.json switch.p4


Some notes on primitive actions used in the source code (ignoring
which of them might be #ifdef'd out, just using grep).  The list of
primitive action names is taken from Table 4 "Primitive Actions" in
v1.0.3 of the P4 spec, Section 9.1 "Primitive Actions".

 40 add_header
 62 copy_header
168 remove_header
891 modify_field
 17 add_to_field (several with negative values)
 22 add
  0 subtract_from_field
  6 subtract
  6 modify_field_with_hash_based_offset
  1 modify_field_rng_uniform
  0 bit_and
  6 bit_or
 19 bit_xor
  3 shift_left
  0 shift_right
  0 truncate
 11 drop
  0 no_op
  6 push
  0 pop
  4 count
  2 execute_meter
  0 register_read
  0 register_write
  1 generate_digest
  0 resubmit
  0 recirculate
  0 clone_ingress_pkt_to_ingress / clone_i2i
  0 clone_egress_pkt_to_ingress / clone_e2i
  5 clone_ingress_pkt_to_egress / clone_i2e
  2 clone_egress_pkt_to_egress / clone_e2e

TBD: Get a more detailed analysis of this, e.g. by counting how many
of each type of operation is done in a table's actions, from the
p4-hlir data structures.

----------------------------------------------------------------------

Options in switch.p4 controlled via #ifdef and #ifndef in the source
code.

% find . -name '*.p4' -o -name '*.h' | xargs grep -h '#ifdef' | sort | uniq -c
   1 #ifdef ACL_DISABLE
   1 #ifdef ACL_RANGE_DISABLE
   2 #ifdef ADV_FEATURES
   5 #ifdef EGRESS_ACL_ENABLE
   3 #ifdef EGRESS_FILTER
  34 #ifdef FABRIC_ENABLE
   1 #ifdef FABRIC_NO_LOCAL_SWITCHING
   8 #ifdef INT_ENABLE
   9 #ifdef INT_EP_ENABLE
   4 #ifdef INT_TRANSIT_ENABLE
   1 #ifdef IPSG_DISABLE
   1 #ifdef IPV4_DISABLE
   1 #ifdef IPV6_DISABLE
   1 #ifdef L2_DISABLE
   1 #ifdef L2_MULTICAST_DISABLE
   1 #ifdef L3_DISABLE
   1 #ifdef L3_MULTICAST_DISABLE
   1 #ifdef MPLS_DISABLE
   2 #ifdef MULTICAST_DISABLE
   1 #ifdef NEGATIVE_MIRRORING_ENABLE
   5 #ifdef OPENFLOW_ENABLE
   2 #ifdef OPENFLOW_ENABLE_L3
   2 #ifdef OPENFLOW_ENABLE_MPLS
   2 #ifdef OPENFLOW_ENABLE_VLAN
   2 #ifdef OPENFLOW_PACKET_IN_OUT
   1 #ifdef OUTER_PIM_BIDIR_OPTIMIZATION
   1 #ifdef PIM_BIDIR_OPTIMIZATION
   7 #ifdef QOS_DISABLE
  11 #ifdef SFLOW_ENABLE
   1 #ifdef STATS_DISABLE
   1 #ifdef STORM_CONTROL_DISABLE
   1 #ifdef STP_DISABLE
   2 #ifdef TUNNEL_DISABLE
   1 #ifdef URPF_DISABLE
   1 #ifdef __TARGET_BMV2__

% find . -name '*.p4' -o -name '*.h' | xargs grep -h '#ifndef' | sort | uniq -c
   4 #ifndef ACL_RANGE_DISABLE
   1 #ifndef ADV_FEATURES
   1 #ifndef CPU_PORT_ID
   2 #ifndef IPSG_DISABLE
  12 #ifndef IPV4_DISABLE
  26 #ifndef IPV6_DISABLE
  10 #ifndef L2_DISABLE
   3 #ifndef L3_MULTICAST_DISABLE
   6 #ifndef METER_DISABLE
   6 #ifndef MIRROR_DISABLE
  16 #ifndef MPLS_DISABLE
  13 #ifndef MULTICAST_DISABLE
   5 #ifndef NAT_DISABLE
   5 #ifndef NVGRE_DISABLE
  19 #ifndef QOS_DISABLE
   9 #ifndef STATS_DISABLE
   3 #ifndef STORM_CONTROL_DISABLE
  12 #ifndef TUNNEL_DISABLE
   3 #ifndef TUNNEL_OVER_IPV6_DISABLE
   3 #ifndef __TARGET_BMV2__

----------------------------------------------------------------------
a + b means a is the number of times symbol occurs in '#ifdef', and b
is the number of times it occurs in '#ifndef'

   1 +  0 ACL_DISABLE         (no effect as far as I can tell)
   1 +  4 ACL_RANGE_DISABLE   (disables L4 src/dst port range lookups)
   2 +  1 ADV_FEATURES        (enables parsing a few more header types, e.g. RARP, NSH, FCOE, TRILL, VNTAG - default disabled)
   0 +  1 CPU_PORT_ID
   5 +  0 EGRESS_ACL_ENABLE
   3 +  0 EGRESS_FILTER
  34 +  0 FABRIC_ENABLE
   1 +  0 FABRIC_NO_LOCAL_SWITCHING
   8 +  0 INT_ENABLE
   9 +  0 INT_EP_ENABLE
   4 +  0 INT_TRANSIT_ENABLE
   1 +  2 IPSG_DISABLE
   1 + 12 IPV4_DISABLE
   1 + 26 IPV6_DISABLE
   1 + 10 L2_DISABLE
   1 +  0 L2_MULTICAST_DISABLE
   1 +  0 L3_DISABLE
   1 +  3 L3_MULTICAST_DISABLE
   0 +  6 METER_DISABLE
   0 +  6 MIRROR_DISABLE
   1 + 16 MPLS_DISABLE
   2 + 13 MULTICAST_DISABLE
   0 +  5 NAT_DISABLE
   1 +  0 NEGATIVE_MIRRORING_ENABLE
   0 +  5 NVGRE_DISABLE
   5 +  0 OPENFLOW_ENABLE
   2 +  0 OPENFLOW_ENABLE_L3
   2 +  0 OPENFLOW_ENABLE_MPLS
   2 +  0 OPENFLOW_ENABLE_VLAN
   2 +  0 OPENFLOW_PACKET_IN_OUT
   1 +  0 OUTER_PIM_BIDIR_OPTIMIZATION
   1 +  0 PIM_BIDIR_OPTIMIZATION
   7 + 19 QOS_DISABLE
  11 +  0 SFLOW_ENABLE
   1 +  9 STATS_DISABLE
   1 +  3 STORM_CONTROL_DISABLE
   1 +  0 STP_DISABLE
   2 + 12 TUNNEL_DISABLE
   0 +  3 TUNNEL_OVER_IPV6_DISABLE
   1 +  0 URPF_DISABLE
   1 +  3 __TARGET_BMV2__
