Meaning of some if conditions:

(l3_metadata.lkp_ip_type == 1) - table validate_outer_ipv4_packet has
looked at IPv4 version, TTL, and most significant 8 bits of source
address, and determined it is a valid IPv4 packet.  P4 source:
(l3_metadata.lkp_ip_type == IPTYPE_IPV4)


(l3_metadata.lkp_ip_type == 2) - table validate_outer_ipv6_packet has
looked at IPv6 version, TTL, and most significant 16 bits of source
address, and determined it is a valid IPv6 packet.  P4 source:
(l3_metadata.lkp_ip_type == IPTYPE_IPV6)



#define BYPASS_L2                              0x0001
#define BYPASS_L3                              0x0002
#define BYPASS_ACL                             0x0004
#define BYPASS_QOS                             0x0008
#define BYPASS_METER                           0x0010
#define BYPASS_SYSTEM_ACL                      0x0020
#define BYPASS_PKT_VALIDATION                  0x0040
#define BYPASS_SMAC_CHK                        0x0080
#define BYPASS_ALL                             0xFFFF

((ingress_metadta.bypass_lookups & 1) == 0) - _do not_ BYPASS_L2,
i.e. do L2 processing.  P4 source: DO_LOOKUP(L2)

((ingress_metadta.bypass_lookups & 2) == 0) - _do not_ BYPASS_L3,
i.e. do L3 processing.  P4 source: DO_LOOKUP(L3)

((ingress_metadta.bypass_lookups & 32) == 0) - _do not_
BYPASS_SYSTEM_ACL, i.e. do system ACL.  P4 source:
DO_LOOKUP(SYSTEM_ACL)

((ingress_metadta.bypass_lookups & 128) == 0) - _do not_
BYPASS_SMAC_CHK, i.e. do SMAC check.  P4 source: DO_LOOKUP(SMAC_CHK)
