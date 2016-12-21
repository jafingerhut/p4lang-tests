Meaning of some if conditions:

    (l3_metadata.lkp_ip_type == 1)
    P4 source: (l3_metadata.lkp_ip_type == IPTYPE_IPV4)

Table `validate_outer_ipv4_packet` has looked at IPv4 version, TTL,
and most significant 8 bits of source address, and determined it is a
valid IPv4 packet.


    (l3_metadata.lkp_ip_type == 2)
    P4 source: (l3_metadata.lkp_ip_type == IPTYPE_IPV6)

Table `validate_outer_ipv6_packet` has looked at IPv6 version, TTL,
and most significant 16 bits of source address, and determined it is a
valid IPv6 packet.



    ((ingress_metadata.bypass_lookups & 1) == 0)
    P4 source code: DO_LOOKUP(L2)

Do not bypass L2 processing, i.e. do L2 processing.  1 comes from
`#define BYPASS_L2 0x0001`.

It appears that for a normal packet arriving from a switch port,
`DO_LOOKUP(foo)` will always be true,
i.e. `ingress_metdata.bypass_lookups` is 0.  The only purpose of
`bypass_lookups` in switch.p4 appears to be to allow a packet sent
across a switch fabric to optionally skip parts of the packet
processing on the 'egress' part of line card forwarding in a modular
system.

Other values besides 1 that can be ANDed with `bypass_lookups` that
are sometimes found:

      1 - DO_LOOKUP(L2)
      2 - DO_LOOKUP(L3)
      4 - DO_LOOKUP(ACL)
      8 - DO_LOOKUP(QOS)
     16 - DO_LOOKUP(METER)
     32 - DO_LOOKUP(SYSTEM_ACL)
     64 - DO_LOOKUP(PKT_VALIDATION)
    128 - DO_LOOKUP(SMAC_CHK)

    (ingress_metadata.bypass_lookups == 65535)
    P4 source: BYPASS_ALL_LOOKUPS
