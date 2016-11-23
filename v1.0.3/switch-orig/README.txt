This source code was copied from this Github repository, directory `p4src`:

    https://github.com/p4lang/switch

Here is the version of the commit that I copied it from:

    commit cabf7e9d8fabf96846f6d34180e65af33bb87d39
    Author: srikrishnagopu <krishna@barefootnetworks.com>
    Date:   Wed Nov 2 11:01:55 2016 -0700

I found a mention of the primitive shift_left in this message sent to
the p4-dev email list:

    http://lists.p4.org/pipermail/p4-dev_lists.p4.org/2016-October/000513.html

It recommended copying this file

    https://github.com/p4lang/p4c-bm/blob/master/p4c_bm/primitives.json

and then running the p4-graphs command with these extra options:

    p4-graphs --primitives primitives.json switch.p4
