# Introduction

This repository includes sample P4 programs, publicly available, plus
commands used to analyze them, and the output files those commands
produce.

It will contain documentation to help in interpreting these output
files as I learn how myself (e.g. what do the colors of edges
represent in table dependency graphs produced by the p4-graphs
program?).

Related repositories:

* https://github.com/p4lang/p4-hlir - Python source code for
      `p4-validate` and `p4-graphs` programs that parse P4 source code
      and produce HLIR (High Level Intermediate Representation) of the
      program.  This is a collection of Python data structures
      representing things in the program like headers, tables,
      actions, conditional expressions, etc. plus dependencies and
      relationships between them.

* https://github.com/p4lang/switch - source for switch.p4, copied into
      this repository in directory
      [v1.0.3/switch-orig/](v1.0.3/switch-orig/)
