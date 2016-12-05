This output was produced by running this command:

    ./run.sh

The -DFORCE_DEPENDENCY_AFTER_STRIP_MTAG option in that script causes
that symbol to be #define'd while parsing the source code.

This change causes the search key for table `identify_port` to include
field `local_metadata.was_mtagged`, which is modified by one of the
actions of table `strip_mtag`, forcing a dependency so that the two
table accesses cannot occur simultaneously.  As expected, the
resulting minimum number of stages grows by 1.
