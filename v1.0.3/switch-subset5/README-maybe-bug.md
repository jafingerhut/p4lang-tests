I happened to notice that there is no dependency between tables
adjust_lkp_fields and tunnel_lookup_miss.

They both have the same actions, modifying the same metadata fields,
so if one can come sequentially before the other, they ought to have
at least an ACTION dependency between them.


In control ingress block:

Earlier in control block process_port_vlan_mapping,
apply(adjust_lkp_fields) is done, but only on preprocessor condition
#ifdef TUNNEL_DISABLE, and it is NOT #define'd anywhere in the source
code.

Later in control block process_tunnel, apply(tunnel_lookup_miss) is
done, subject to some conditions, both if and on the result type of
apply(tunnel).

However, apply(adjust_lkp_fields) is only done in the 'else' of an
'if' where the 'then' part does apply(tunnel_lookup_miss), so they can
be determined from static code analysis never to both happen on the
same packet.

Perhaps that is why there is no dependency between them in HLIR?  It
would make sense if that is the 
If that is not the reason, they definitely should have a dependency,
because they both can modify the same metadata fields in their
actions, since both tables ahve the _same_ actions.
reason.
