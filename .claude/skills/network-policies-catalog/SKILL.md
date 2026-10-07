---
name: network-policies-catalog
description: Write or edit a CiliumNetworkPolicy. Use when a change deploys a workload into a new namespace or adds a component to an existing one, when `hubble` shows dropped traffic, and when editing an existing policy.
---

Follow [How Network Policies Work](https://eks-forge.readthedocs.io/latest/docs/security/how-network-policies-work/)
for the concepts, and
[Write Network Policies](https://eks-forge.readthedocs.io/latest/docs/security/write-network-policies/)
for the steps (deny the namespace, deploy, find dropped flows with
`hubble observe --verdict DROPPED`, allow each one).

Match existing policies' shape and scoping (`endpointSelector`, label choice, ingress/egress
split), don't invent a new pattern.
