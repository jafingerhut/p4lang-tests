////////////////////////////////////////////////////////////////
//
// mtag-aggregation.p4
//
////////////////////////////////////////////////////////////////

// Include the header definitions and parser (with header instances)
#include "headers.p4"
#include "parser.p4"
#include "actions.p4"  // For actions marked "common_"

////////////////////////////////////////////////////////////////
// check_mtag table:
//   Make sure pkt has mtag; Apply drop or to-cpu policy if not
////////////////////////////////////////////////////////////////

table check_mtag { // Statically programmed w/ one entry
. . . // Reads if mtag valid; drop or copy to CPU
}

////////////////////////////////////////////////////////////////
// identify_port table:
//   Check if up or down facing port as programmed at run time.
////////////////////////////////////////////////////////////////

table identify_port {
. . . // Read ingress_port; call common_set_port_type.
}

////////////////////////////////////////////////////////////////

// Actions to copy the proper field from mtag into the egress spec
action use_mtag_up1() { // This is actually never used on agg switches
    modify_field(standard_metadata.egress_spec, mtag.up1);
}
action use_mtag_up2() {
    modify_field(standard_metadata.egress_spec, mtag.up2);
}
action use_mtag_down1() {
    modify_field(standard_metadata.egress_spec, mtag.down1);
}
action use_mtag_down2() {
    modify_field(standard_metadata.egress_spec, mtag.down2);
}

// Table to select output spec from mtag
table select_output_port {
    reads {
        local_metadata.port_type  : exact; // Up, down, level 1 or 2.
    }
    actions {
        use_mtag_up1;
        use_mtag_up2;
        use_mtag_down1;
        use_mtag_down2;
        // If port type is not recognized, previous policy applied
        no_op;
    }
    max_size : 4; // Only need one entry per port type
}

////////////////////////////////////////////////////////////////
// Control function definitions
////////////////////////////////////////////////////////////////

// The ingress control function
control ingress {
    // Verify mTag state and port are consistent
    apply(check_mtag);
    apply(identify_port);
    apply(select_output_port);
}

// No egress function used in the mtag-agg example.
