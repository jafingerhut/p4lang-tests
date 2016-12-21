/*
Copyright 2013-present Barefoot Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#define IFINDEX_BIT_WIDTH                      16
#define VRF_BIT_WIDTH                          16
#define BD_BIT_WIDTH                           16


header_type ingress_intrinsic_metadata_t {
    fields {
        resubmit_flag : 1;              // flag distinguishing original packets
                                        // from resubmitted packets.

        ingress_global_tstamp : 48;     // global timestamp (ns) taken upon
                                        // arrival at ingress.

        mcast_grp : 16;                 // multicast group id (key for the
                                        // mcast replication table)

        deflection_flag : 1;            // flag indicating whether a packet is
                                        // deflected due to deflect_on_drop.
        deflect_on_drop : 1;            // flag indicating whether a packet can
                                        // be deflected by TM on congestion drop

        enq_qdepth : 19;                // queue depth at the packet enqueue
                                        // time.
        enq_tstamp : 32;                // time snapshot taken when the packet
                                        // is enqueued (in nsec).
        enq_congest_stat : 2;           // queue congestion status at the packet
                                        // enqueue time.

        deq_qdepth : 19;                // queue depth at the packet dequeue
                                        // time.
        deq_congest_stat : 2;           // queue congestion status at the packet
                                        // dequeue time.
        deq_timedelta : 32;             // time delta between the packet's
                                        // enqueue and dequeue time.

        mcast_hash : 13;                // multicast hashing

        egress_rid : 16;                // Replication ID for multicast

        lf_field_list : 32;             // Learn filter field list

        priority : 3;                   // set packet priority

        ingress_cos: 3;                 // ingress cos

        packet_color: 2;                // packet color

        qid: 5;                         // queue id
    }
}
metadata ingress_intrinsic_metadata_t intrinsic_metadata;


/*
 * L2 Metadata
 */

header_type l2_metadata_t {
    fields {
        lkp_mac_sa : 48;
        lkp_mac_da : 48;
        lkp_pkt_type : 3;
        lkp_mac_type : 16;
        lkp_pcp: 3;

        l2_nexthop : 16;                       /* next hop from l2 */
        l2_nexthop_type : 2;                   /* ecmp or nexthop */
        l2_redirect : 1;                       /* l2 redirect action */
        l2_src_miss : 1;                       /* l2 source miss */
        l2_src_move : IFINDEX_BIT_WIDTH;       /* l2 source interface mis-match */
        stp_group: 10;                         /* spanning tree group id */
        stp_state : 3;                         /* spanning tree port state */
        bd_stats_idx : 16;                     /* ingress BD stats index */
        learning_enabled : 1;                  /* is learning enabled */
        port_vlan_mapping_miss : 1;            /* port vlan mapping miss */
        same_if_check : IFINDEX_BIT_WIDTH;     /* same interface check */
    }
}

metadata l2_metadata_t l2_metadata;


/*
 * L3 Metadata
 */

header_type l3_metadata_t {
    fields {
        lkp_ip_type : 2;
        lkp_ip_version : 4;
        lkp_ip_proto : 8;
        lkp_dscp : 8;
        lkp_ip_ttl : 8;
        lkp_l4_sport : 16;
        lkp_l4_dport : 16;
        lkp_outer_l4_sport : 16;
        lkp_outer_l4_dport : 16;

        vrf : VRF_BIT_WIDTH;                   /* VRF */
        rmac_group : 10;                       /* Rmac group, for rmac indirection */
        rmac_hit : 1;                          /* dst mac is the router's mac */
        urpf_mode : 2;                         /* urpf mode for current lookup */
        urpf_hit : 1;                          /* hit in urpf table */
        urpf_check_fail :1;                    /* urpf check failed */
        urpf_bd_group : BD_BIT_WIDTH;          /* urpf bd group */
        fib_hit : 1;                           /* fib hit */
        fib_nexthop : 16;                      /* next hop from fib */
        fib_nexthop_type : 2;                  /* ecmp or nexthop */
        same_bd_check : BD_BIT_WIDTH;          /* ingress bd xor egress bd */
        nexthop_index : 16;                    /* nexthop/rewrite index */
        routed : 1;                            /* is packet routed? */
        outer_routed : 1;                      /* is outer packet routed? */
        mtu_index : 8;                         /* index into mtu table */
        l3_copy : 1;                           /* copy packet to CPU */
        l3_mtu_check : 16 (saturating);        /* result of mtu check */

        egress_l4_sport : 16;
        egress_l4_dport : 16;
    }
}

metadata l3_metadata_t l3_metadata;


/*
 * IPv4 metadata
 */
header_type ipv4_metadata_t {
    fields {
        lkp_ipv4_sa : 32;
        lkp_ipv4_da : 32;
        ipv4_unicast_enabled : 1;      /* is ipv4 unicast routing enabled */
        ipv4_urpf_mode : 2;            /* 0: none, 1: strict, 3: loose */
    }
}

metadata ipv4_metadata_t ipv4_metadata;


/*
 * IPv6 Metadata
 */
header_type ipv6_metadata_t {
    fields {
        lkp_ipv6_sa : 128;                     /* ipv6 source address */
        lkp_ipv6_da : 128;                     /* ipv6 destination address*/

        ipv6_unicast_enabled : 1;              /* is ipv6 unicast routing enabled on BD */
        ipv6_src_is_link_local : 1;            /* source is link local address */
        ipv6_urpf_mode : 2;                    /* 0: none, 1: strict, 3: loose */
    }
}
metadata ipv6_metadata_t ipv6_metadata;


/*
 * Tunnel metadata
 */
header_type tunnel_metadata_t {
    fields {
        ingress_tunnel_type : 5;               /* tunnel type from parser */
        tunnel_vni : 24;                       /* tunnel id */
        mpls_enabled : 1;                      /* is mpls enabled on BD */
        mpls_label: 20;                        /* Mpls label */
        mpls_exp: 3;                           /* Mpls Traffic Class */
        mpls_ttl: 8;                           /* Mpls Ttl */
        egress_tunnel_type : 5;                /* type of tunnel */
        tunnel_index: 14;                      /* tunnel index */
        tunnel_src_index : 9;                  /* index to tunnel src ip */
        tunnel_smac_index : 9;                 /* index to tunnel src mac */
        tunnel_dst_index : 14;                 /* index to tunnel dst ip */
        tunnel_dmac_index : 14;                /* index to tunnel dst mac */
        vnid : 24;                             /* tunnel vnid */
        tunnel_terminate : 1;                  /* is tunnel being terminated? */
        tunnel_if_check : 1;                   /* tun terminate xor originate */
        egress_header_count: 4;                /* number of mpls header stack */
        inner_ip_proto : 8;                    /* Inner IP protocol */
        skip_encap_inner : 1;                  /* skip encap_process_inner */
    }
}
metadata tunnel_metadata_t tunnel_metadata;


/* METADATA */

header_type ingress_metadata_t {
    fields {
        ingress_port : 9;                      /* input physical port */
        ifindex : IFINDEX_BIT_WIDTH;           /* input interface index */
        egress_ifindex : IFINDEX_BIT_WIDTH;    /* egress interface index */
        port_type : 2;                         /* ingress port type */

        outer_bd : BD_BIT_WIDTH;               /* outer BD */
        bd : BD_BIT_WIDTH;                     /* BD */

        drop_flag : 1;                         /* if set, drop the packet */
        drop_reason : 8;                       /* drop reason */
        control_frame: 1;                      /* control frame */
        bypass_lookups : 16;                   /* list of lookups to skip */
        sflow_take_sample : 32 (saturating);
    }
}

header_type egress_metadata_t {
    fields {
        bypass : 1;                            /* bypass egress pipeline */
        port_type : 2;                         /* egress port type */
        payload_length : 16;                   /* payload length for tunnels */
        smac_idx : 9;                          /* index into source mac table */
        bd : BD_BIT_WIDTH;                     /* egress inner bd */
        outer_bd : BD_BIT_WIDTH;               /* egress inner bd */
        mac_da : 48;                           /* final mac da */
        routed : 1;                            /* is this replica routed */
        same_bd_check : BD_BIT_WIDTH;          /* ingress bd xor egress bd */
        drop_reason : 8;                       /* drop reason */
        ifindex : IFINDEX_BIT_WIDTH;           /* egress interface index */
    }
}

metadata ingress_metadata_t ingress_metadata;
metadata egress_metadata_t egress_metadata;
