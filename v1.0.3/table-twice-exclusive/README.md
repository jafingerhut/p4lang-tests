This is a small example that does apply(table4) twice in the ingress
control block, but they are mutually exclusive occurrences, i.e. one
is in the then branch of an if statement, the other in the else branch
of the same if statement.

Before this commit to p4-hlir:

----------------------------------------------------------------------
commit 005108dca8f3b75b35a3b767404eb245125eabd8
Author: Calin Cascaval <cascaval@barefootnetworks.com>
Date:   Fri Dec 16 17:02:19 2016 -0800

    Allow mutually exclusive control flows to invoke the same table
    
    Under some very stringent conditions.
    
    Mechanics: Invokes the recursive paths of a p4_conditional_node with
    empty visited sets, and does the check at the end of the conditional
    traversal. The check consists of two parts: first checks that a table
    in both paths has no next pointer set. And then it checks that the
    tables in each path does not exist in the visited set.
----------------------------------------------------------------------

attempting to compile this P4 program gives the following error:

----------------------------------------------------------------------
ERROR: Table 'table4' is invoked multiple times.
Error while building HLIR
----------------------------------------------------------------------

After that commit, the program compiles with no errors.
