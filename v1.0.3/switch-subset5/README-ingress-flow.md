Comments like '1 action' or '5 actions' for an apply() on a table
simply mean how many different possible actions are in the table's
`actions` block.  It says nothing about how complex those actions are.



control ingress {  // switch.p4
    /* input mapping - derive an ifindex */
    //process_ingress_port_mapping(); // port.p4
    apply(ingress_port_mapping); // 1 action, 2 modify_field
    apply(ingress_port_properties);  // 1 action, 7 modify_field

    /* process outer packet headers */
    //process_validate_outer_header(); // port.p4
    apply(validate_outer_ethernet) {  // TCAM search on SMAC, DMAC, and 2 VLAN headers valid/invalid.  13 actions, each of which does 2 or 3 modify_field
        malformed_outer_ethernet_packet {
        }
        default {
            if (valid(ipv4)) {
                //validate_outer_ipv4_header();  // ipv4.p4
                apply(validate_outer_ipv4_packet);  // checks IPv4 version, TTL, and upper 8 bits of IPv4 SA (probably to ensure it isn't multicast or 127.x.x.x).  2 actions, each of which does 2 or 3 modify_field
            } else {
                if (valid(ipv6)) {
                    //validate_outer_ipv6_header(); // ipv6.p4
                    apply(validate_outer_ipv6_packet); // checks IPv6 version, TTL, and upper 16 bits of IPv6 SA (probably similar to IPv4 checks above).  2 actions, each of which does 2 or 3 modify_field
                } else {
#ifndef MPLS_DISABLE
                    if (valid(mpls[0])) {
                        //validate_mpls_header(); // tunnel.p4
                        apply(validate_mpls_packet);  // checks 1, 2, or 3 top MPLS label/EOS pairs.  3 actions, each of which does 2 modify_field, simply extracting 1 set of label/exp fields from one selected MPLS header
                    }
#endif
                }
            }
        }
    }

    /* read and apply system configuration parametes */
    //process_global_params(); // switch_config.p4
    apply(switch_config_params);  // no search key fields, so really simply reading a global config register.  1 action, 6 modify_field

    /* derive bd and its properties  */
    //process_port_vlan_mapping();  // port.p4
    apply(port_vlan_mapping);  // exact match on ifindex and up to 2 VLAN ids.  2 actions, 21 modify_field (common case) and 1 modify_field (on miss, which is used in system_acl at end to decide what to do with packet, e.g. drop, copy to CPU)
    // It appears that TUNNEL_DISABLE is not #define'd, so this is not in there
#ifdef TUNNEL_DISABLE
    apply(adjust_lkp_fields);
#endif

    /* spanning tree state checks */
    process_spanning_tree();

    /* ingress qos map */
    process_ingress_qos_map();

    /* IPSG */
    process_ip_sourceguard();

    /* INT src,sink determination */
    process_int_endpoint();

    /* ingress sflow determination */
    process_ingress_sflow();

    /* tunnel termination processing */
    process_tunnel();

    /* storm control */
    process_storm_control();

    if (ingress_metadata.port_type != PORT_TYPE_FABRIC) {
#ifndef MPLS_DISABLE
        if (not (valid(mpls[0]) and (l3_metadata.fib_hit == TRUE))) {
#endif /* MPLS_DISABLE */
            /* validate packet */
            process_validate_packet();

            /* perform ingress l4 port range */
            process_ingress_l4port();

            /* l2 lookups */
            process_mac();

            /* port and vlan ACL */
            if (l3_metadata.lkp_ip_type == IPTYPE_NONE) {
                process_mac_acl();
            } else {
                process_ip_acl();
            }

            apply(rmac) {
                rmac_miss {
                    process_multicast();
                }
                default {
                    if (DO_LOOKUP(L3)) {
                        if ((l3_metadata.lkp_ip_type == IPTYPE_IPV4) and
                            (ipv4_metadata.ipv4_unicast_enabled == TRUE)) {
                            /* router ACL/PBR */
                            process_ipv4_racl();
                            process_ipv4_urpf();
                            process_ipv4_fib();

                        } else {
                            if ((l3_metadata.lkp_ip_type == IPTYPE_IPV6) and
                                (ipv6_metadata.ipv6_unicast_enabled == TRUE)) {
                                /* router ACL/PBR */
                                process_ipv6_racl();
                                process_ipv6_urpf();
                                process_ipv6_fib();
                            }
                        }
                        process_urpf_bd();
                    }
                }
            }

            /* ingress NAT */
            process_ingress_nat();
#ifndef MPLS_DISABLE
        }
#endif /* MPLS_DISABLE */
    }

    process_meter_index();

    /* compute hashes based on packet type  */
    process_hashes();

    process_meter_action();

    if (ingress_metadata.port_type != PORT_TYPE_FABRIC) {
        /* update statistics */
        process_ingress_bd_stats();
        process_ingress_acl_stats();
        process_storm_control_stats();

        /* decide final forwarding choice */
        process_fwd_results();

        /* ecmp/nexthop lookup */
        process_nexthop();

#ifdef OPENFLOW_ENABLE
        /* openflow processing for ingress */
        process_ofpat_ingress();
#endif /* OPENFLOW_ENABLE */

        if (ingress_metadata.egress_ifindex == IFINDEX_FLOOD) {
            /* resolve multicast index for flooding */
            process_multicast_flooding();
        } else {
            /* resolve final egress port for unicast traffic */
            process_lag();
        }

        /* generate learn notify digest if permitted */
        process_mac_learning();
    }

    /* resolve fabric port to destination device */
    process_fabric_lag();

    /* set queue id for tm */
    process_traffic_class();

    if (ingress_metadata.port_type != PORT_TYPE_FABRIC) {
        /* system acls */
        process_system_acl();
    }
}
