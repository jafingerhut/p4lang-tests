This output was produced by running this command:

    p4-graphs ../mtag-edge.p4

but after editing ../mtag-edge.p4 to change this line:

    #undef EXTRA_TEST_TABLE

to this:

    #define EXTRA_TEST_TABLE

This adds a new table named `extra_test_table`, and causes it to be
applied in the ingress pipeline if `local_metadata.ingress_error` is
not 0.
