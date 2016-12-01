This output was produced by running this command:

    ./run.sh

The -DEXTRA_TEST_TABLE option causes that symbol to be #define'd while
parsing the source code.

This adds a new table named `extra_test_table`, and causes it to be
applied in the ingress pipeline if `local_metadata.ingress_error` is
not 0.
