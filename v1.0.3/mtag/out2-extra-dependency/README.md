This output was produced by running this command:

p4-graphs ../mtag-edge.p4

but after editing ../mtag-edge.p4 to change this line:

    #undef FORCE_DEPENDENCY_AFTER_STRIP_MTAG

to this:

    #define FORCE_DEPENDENCY_AFTER_STRIP_MTAG

This change causes the search key for table `identify_port` to include
field `local_metadata.was_mtagged`, which is modified by one of the
actions of table `strip_mtag`, forcing a dependency so that the two
table accesses cannot occur simultaneously.
