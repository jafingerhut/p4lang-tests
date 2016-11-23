This is the original unmodified example code for mtag-edge from
Section 15.8.1 of "The P4 Language Specification", version 1.0.3,
dated November 2, 2016 obtained from the P4 web site at http://p4.org

It intentionally leaves out a definition for the table 'local_switching'.

It contains some things that causes the program p4-graphs to issue
errors and warnings, such as the use of primitive operations as table
actions, and arithmetic expressions in the values of instance_count
and size.

See the sibling directory mtag for a version that p4-graphs accepts
without errors.
