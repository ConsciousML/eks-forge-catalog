---
name: network-policies-catalog
description: Write or edit a CiliumNetworkPolicy. Use when building a feature that introduces a new namespace, or a new component in an existing namespace, and when editing an existing NetworkPolicy.
---

Follow [How Network Policies Work](https://eks-forge.readthedocs.io/latest/docs/security/how-network-policies-work/)
for the concepts, and
[Write Network Policies](https://eks-forge.readthedocs.io/latest/docs/security/write-network-policies/)
for the steps (deny the namespace, deploy, find dropped flows with
`hubble observe --verdict DROPPED`, allow each one).

Match existing policies' shape and scoping (`endpointSelector`, label choice, ingress/egress
split), don't invent a new pattern.
