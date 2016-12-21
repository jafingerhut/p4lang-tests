#define TRUE  1
#define FALSE 0

#define L2_UNICAST    1
#define L2_BROADCAST  4

#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/metadata.p4"


header_type example_metadata_t {
    fields {
        fldA : 8;
        fldB : 8;
        fldC : 8;
        fldD : 8;
        fldE : 8;
    }
}
metadata example_metadata_t example_metadata;


action nop() {
}

action malformed_outer_ethernet_packet(drop_reason) {
    modify_field(ingress_metadata.drop_flag, TRUE);
    modify_field(ingress_metadata.drop_reason, drop_reason);
}

action set_valid_outer_unicast_packet_untagged() {
    modify_field(l2_metadata.lkp_pkt_type, L2_UNICAST);
    modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
}

action set_valid_outer_broadcast_packet_untagged(table_result_field1) {
    modify_field(l2_metadata.lkp_pkt_type, L2_BROADCAST);
    modify_field(l2_metadata.lkp_mac_type, ethernet.etherType);
    modify_field(example_metadata.fldE, table_result_field1);
}


/* A subset of switch.p4's table validate_outer_ethernet */
table table1 {
    reads {
        ethernet.dstAddr : ternary;
    }
    actions {
        malformed_outer_ethernet_packet;
        set_valid_outer_unicast_packet_untagged;
        set_valid_outer_broadcast_packet_untagged;
    }
    size : 16;
}

action do_something2(table_result_field1) {
    modify_field(example_metadata.fldB, table_result_field1);
}

table table2 {
    reads {
//        l2_metadata.lkp_pkt_type : ternary;
        ethernet.srcAddr : ternary;
    }
    actions {
        nop;
        do_something2;
    }
    size : 16;
}

action do_something3(table_result_field1) {
    modify_field(example_metadata.fldC, table_result_field1);
}

table table3 {
    reads {
//        l2_metadata.lkp_mac_type : ternary;
        ethernet.etherType : ternary;
    }
    actions {
        do_something3;
    }
    size : 16;
}

action do_something4(table_result_field1) {
    modify_field(example_metadata.fldD, table_result_field1);
}

table table4 {
    reads {
//        ingress_metadata.drop_reason : ternary;
        example_metadata.fldD : ternary;
    }
    actions {
        do_something4;
    }
    size : 16;
}

table table5 {
    reads {
        example_metadata.fldB : ternary;
        example_metadata.fldC : ternary;
        example_metadata.fldD : ternary;
        example_metadata.fldE : ternary;
    }
    actions {
        nop;
    }
    size : 16;
}


control ingress {
    apply(table1);
    if (ethernet.etherType == 1) {
        apply(table2);
    } else {
        apply(table3);
        apply(table4);
    }
    apply(table5);
}


/* Just a dummy table so that there are no errors processing the
 * egress path. */
table dummy_egress_table {
    actions {
        nop;
    }
    size : 1;
}

control egress {
    apply(dummy_egress_table);
}
