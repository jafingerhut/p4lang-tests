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

#include "includes/p4features.h"
#include "includes/drop_reason_codes.h"
#include "includes/cpu_reason_codes.h"
#include "includes/p4_table_sizes.h"
#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/defines.p4"
#include "includes/intrinsic.p4"

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

/* Global config information */
header_type global_config_metadata_t {
    fields {
        enable_dod : 1;                        /* Enable Deflection-on-Drop */
        /* Add more global parameters such as switch_id.. */
    }
}
metadata global_config_metadata_t global_config_metadata;

#include "switch_config.p4"
#ifdef OPENFLOW_ENABLE
#include "openflow.p4"
#endif /* OPENFLOW_ENABLE */
#include "port.p4"
#include "l2.p4"
#include "l3.p4"
#include "ipv4.p4"
#include "ipv6.p4"
#include "tunnel.p4"
#include "acl.p4"
#include "nat.p4"
#include "multicast.p4"
#include "nexthop.p4"
#include "rewrite.p4"
#include "security.p4"
#include "fabric.p4"
#include "egress_filter.p4"
#include "mirror.p4"
#include "int_transit.p4"
#include "hashes.p4"
#include "meter.p4"
#include "sflow.p4"
#include "qos.p4"

action nop() {
}

action on_miss() {
}

control ingress {
    /* l2 lookups */
    process_mac();

    apply(rmac) {
        rmac_miss {
            process_multicast();
        }
        default {
            if (DO_LOOKUP(L3)) {
                if ((l3_metadata.lkp_ip_type == IPTYPE_IPV4) and
                    (ipv4_metadata.ipv4_unicast_enabled == TRUE)) {
                    process_ipv4_fib();

                } else {
                    if ((l3_metadata.lkp_ip_type == IPTYPE_IPV6) and
                        (ipv6_metadata.ipv6_unicast_enabled == TRUE)) {
                        process_ipv6_fib();
                    }
                }
            }
        }
    }

    /* decide final forwarding choice */
    process_fwd_results();

    /* ecmp/nexthop lookup */
    process_nexthop();

    /* resolve final egress port for unicast traffic */
    process_lag();

    /* system acls */
    process_system_acl();
}

control egress {
    /* multi-destination replication */
    process_replication();

    /* determine egress port properties */
    apply(egress_port_mapping) {
        egress_port_type_normal {
            /* strip vlan header */
            process_vlan_decap();

            /* perform tunnel decap */
            process_tunnel_decap();

            /* apply nexthop_index based packet rewrites */
            process_rewrite();

            /* rewrite source/destination mac if needed */
            process_mac_rewrite();

            /* egress mtu checks */
            process_mtu();
        }
    }

    /* egress filter */
    process_egress_filter();

    /* apply egress acl */
    process_egress_system_acl();
}
