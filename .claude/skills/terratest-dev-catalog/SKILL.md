---
name: terratest-dev-catalog
description: Run the eks-forge-live Terratest endpoint checks against the live `dev` stack. Use after a dev deploy once every ArgoCD app is Synced and Healthy, as the end-to-end check of step 5 in `github-workflow-catalog`.
---

`TestStackExists` in `eks-forge-live/tests` asserts an already-deployed stack. It never applies or
destroys. It polls every hostname in `endpointChecks` (`tests/endpoint_checks_test.go`), and logs in
to ArgoCD and Grafana. It doesn't check AWS resources or network policies. Verify those with
read-only `aws` calls and `hubble observe --verdict DROPPED`.

## Prerequisites

- A checkout of `eks-forge-live` next to this repo (`../eks-forge-live`).
- `aws sts get-caller-identity` resolves.
- Every ArgoCD app is Synced and Healthy:
  ```bash
  kubectl get applications -n argocd
  ```
- Tailscale is connected. Private hostnames only resolve over the tailnet. Check with
  `tailscale status`. If it prints `Tailscale is stopped.`, **wait**: ask the user to connect it.
  Never start it yourself.

## Run

The test reads the stack at `../live/<TERRATEST_TARGET_ENVIRONMENT>/eks/stack`, and the dev stack
lives in this repo. Link it into the live checkout for the run, from this repo's root:
```bash
ln -s "$PWD/pipelines/dev" ../eks-forge-live/live/dev
```

`AWS_REGION` isn't in `.env`. Pass the region from `pipelines/region.hcl`:
```bash
source .env
(cd ../eks-forge-live/tests && \
  AWS_REGION=<region> TERRATEST_TARGET_ENVIRONMENT=dev \
  go test -v -run 'TestStackExists$' -timeout 10m) > <log-file> 2>&1
```

Give the user the log file path and `tail -f <log-file>`, as in `working-against-live-infra-catalog`.

Always remove the link afterwards, pass or fail, and check the live checkout is clean:
```bash
rm ../eks-forge-live/live/dev
git -C ../eks-forge-live status --short
```

## Report

- **Passed**: the `--- PASS` line and its duration.
- **Failed**: the `Error:` and `Messages:` lines from the log, and the hostname that failed.
