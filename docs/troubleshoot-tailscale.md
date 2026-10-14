{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
This guide shows you how to fix the access to your cluster's private tools over [Tailscale](/docs/networking/tailscale/).

Go to the section of your problem below.

## Internal Endpoints Are Unreachable on macOS

A private hostname, such as `argocd.private.<env>.<base_domain>`, doesn't load in your browser while you're connected to Tailscale. After you reconnect, macOS can keep its previous DNS configuration, so the hostname never reaches the [Split DNS](/docs/networking/tailscale/#4-connector-and-split-dns) resolver.

First, check that the hostname resolves, replacing `<hostname>`:
```bash
dig +short <hostname>
```

If it prints nothing, ExternalDNS hasn't created the record yet, or your machine doesn't use the Tailscale DNS configuration. Make Tailscale apply it again:
```bash
tailscale set --accept-dns=false
tailscale set --accept-dns=true
```

Run `dig` again. If it now prints a private IP address but the page still doesn't load, flush the DNS cache of macOS:
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

If `dig` still prints nothing after a few minutes, check that the application behind the hostname is `Synced` and `Healthy`:
```bash
kubectl get app -n argocd
```
