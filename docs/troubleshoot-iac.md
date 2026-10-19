{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
## The App of Apps Uninstall Times Out

The destroy fails on the `eks/addons/argocd/app_of_apps` unit with:
```text
Error: Error uninstalling release

Unable to uninstall Helm release app-of-apps: uninstallation completed with
2 error(s): Get
"https://<cluster-endpoint>/apis/argoproj.io/v1alpha1/namespaces/argocd/applications/app-of-apps":
read tcp <local-ip>:<port>-><vpc-ip>:443: read: operation timed out
```

You were connected to Tailscale, so your calls to the cluster API went through the [Tailscale Connector](/docs/networking/tailscale/#4-connector-and-split-dns), which the destroy removed halfway.

Disconnect from Tailscale by running `tailscale down`, or with the button in the Tailscale client. Then check that the cluster answers:
```bash
kubectl get ns
```

Finally, run the destroy again from `<stack-dir>`:
```bash
terragrunt run --all destroy --non-interactive --no-stack-generate
```

## The Kubernetes Resources Can't Be Destroyed

The destroy keeps failing on the units under `eks/addons`, which manage the resources inside the cluster through the `kubernetes` and `helm` providers. For example:
- **The cluster API doesn't answer in time**, so the providers fail with:
  ```text
  Error: Plugin error

  The plugin returned an unexpected error from
  plugin6.(*GRPCProvider).PlanResourceChange: rpc error: code = Unknown desc
  = failed to determine resource type ID: cannot get OpenAPI foundry: failed
  get OpenAPI spec: context deadline exceeded
  ```
- **A Helm release doesn't uninstall**, and the unit fails with `Error uninstalling release` even though you're disconnected from Tailscale (see [The App of Apps Uninstall Times Out](#the-app-of-apps-uninstall-times-out)).
- **You generated the stack from another branch or tag than the one that's deployed**, so its units no longer match what runs in the cluster.

Run the destroy again first. If it keeps failing, follow the steps below: they destroy the cluster without these two providers.

Disconnect from Tailscale by running `tailscale down`, or with the button in the Tailscale client, since the steps below remove the [Tailscale Connector](/docs/networking/tailscale/#4-connector-and-split-dns).

Then set the variables the commands below read, replacing `<region-code>` with your region and `<env>` with your [environment](/docs/iac/#environments) (e.g. `dev`):
```bash
export AWS_REGION=<region-code>
export ENVIRONMENT=<env>
export BUCKET="tofu-state-$(aws sts get-caller-identity --query Account --output text)-${AWS_REGION}-${ENVIRONMENT}"
```

### Stop ArgoCD

ArgoCD recreates every resource you delete from an application it syncs. Stop its application controller, so what you delete in the next steps stays deleted:
```bash
kubectl scale statefulset argocd-application-controller -n argocd --replicas=0
```

### Delete the Routes and Ingresses

Delete the routes, gateways, and ingresses of the cluster, so the AWS Load Balancer Controller and ExternalDNS remove their load balancers and DNS records before the cluster is gone:
```bash
kubectl delete httproute -A --all
kubectl delete gateway -A --all
kubectl delete ingress -A --all
```

Check that the load balancers are gone. This prints `[]` when they are:
```bash
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(LoadBalancerName,'k8s')].LoadBalancerName"
```

Then list the hosted zones of your environment:
```bash
aws route53 list-hosted-zones \
  --query "HostedZones[?contains(Name,'${ENVIRONMENT}.')].[Id,Name]" \
  --output text
```

Check that the DNS records are gone too, replacing `<zone-id>` with each ID the command above printed. This prints `[]` when they are:
```bash
aws route53 list-resource-record-sets --hosted-zone-id <zone-id> \
  --query "ResourceRecordSets[?Type!='NS' && Type!='SOA'].Name"
```

### Delete the Namespaces

Delete the namespaces whose resources live outside the cluster, such as EBS volumes and Tailscale devices:
```bash
kubectl delete ns monitoring loki tailscale
```

Leave the `argocd` namespace: nothing in it lives outside the cluster, and its applications can't be deleted while the application controller is stopped.

### Destroy the Cluster Unit

The `eks/cluster` unit only uses the `aws` provider, so it destroys without the cluster API. From `<stack-dir>`:
```bash
cd .terragrunt-stack/eks/cluster
terragrunt destroy
```

### Destroy the Rest of the Stack

Once the cluster is gone, Terragrunt skips the units under `eks/addons` that use the `kubernetes` and `helm` providers, so the rest of the stack destroys. From `<stack-dir>`:
```bash
terragrunt run --all destroy --non-interactive --no-stack-generate
```

The other units under `eks/addons`, such as the IAM roles and the Loki buckets, only use the `aws` provider and are destroyed by this command. If one of them fails, fix it and run the command again before going further: the next step removes its state too.

### Remove the State of the Add-on Units

The skipped units keep their state, which now points at resources that no longer exist. Set the path of the add-on units in the state bucket, replacing `<env-dir>` with the directory of your stack: `dev` in your catalog fork, even for [another environment](/docs/iac/add-a-dev-environment/), or `<env>` in your live fork:
```bash
export PREFIX="<env-dir>/eks/stack/.terragrunt-stack/eks/addons"
```

Then continue at [Remove the State of a Directory of Units](#remove-the-state-of-a-directory-of-units), without setting `BUCKET` and `PREFIX` again.

### Check for Leftover Resources

In the AWS console, check that nothing billable is left in your region:
- **VPC**: the VPC, its subnets, its NAT gateways, and their Elastic IPs
- **EC2**: instances, load balancers, and EBS volumes (see [Delete Leftover EBS Volumes](/docs/iac/remove-eks-forge/#delete-leftover-ebs-volumes))
- **EKS**: the cluster and its node group
- **Secrets Manager**: the secrets prefixed with your environment
- **IAM**: the roles prefixed with your environment

## A Node Group Stays in `DELETING`

The destroy of the `eks/cluster` unit hangs on the node group until it times out, and the EKS console keeps showing the node group as `Deleting`.

Set the name of your cluster, replacing `<env>` with your [environment](/docs/iac/#environments) (e.g. `dev`), then read the name of its node group:
```bash
export CLUSTER_NAME=<env>-cluster
export NODE_GROUP=$(aws eks list-nodegroups --cluster-name "$CLUSTER_NAME" \
  --query 'nodegroups[0]' --output text)
```

Check its status, and what EKS reports as blocking it:
```bash
aws eks describe-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP" \
  --query 'nodegroup.{status:status,issues:health.issues}'
```

Delete the launch template of the node group, so no new instance starts:
```bash
aws ec2 delete-launch-template --launch-template-id "$(aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP" \
  --query 'nodegroup.launchTemplate.id' --output text)"
```

Then terminate its instances:
```bash
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances \
  --filters "Name=tag:eks:cluster-name,Values=$CLUSTER_NAME" \
    "Name=tag:eks:nodegroup-name,Values=$NODE_GROUP" \
    "Name=instance-state-name,Values=pending,running" \
  --query 'Reservations[].Instances[].InstanceId' --output text)
```

Wait for the node group to be deleted:
```bash
aws eks wait nodegroup-deleted --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP"
```

If the wait fails because the node group ended in `DELETE_FAILED`, delete it, then wait again:
```bash
aws eks delete-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP"
```

Finally, run the destroy again from `<stack-dir>`, so Terragrunt deletes the cluster:
```bash
terragrunt run --all destroy --non-interactive --no-stack-generate
```

## State Data in S3 Doesn't Have the Expected Content

A unit fails on `init` with:
```text
Error refreshing state: state data in S3 does not have the expected content.
```

Its state file in S3 was deleted or replaced, but its digest is still in the DynamoDB lock table. To start the unit again from an empty state, remove both. Do the same when a state points at resources that no longer exist.

:::warning
Removing a state makes Terragrunt forget every resource of the unit. Only do it when these resources are already destroyed. Otherwise, they stay in your AWS account, and the next apply creates them a second time.
:::

Set the state bucket of your environment, replacing `<region-code>` and `<env>`. Every environment shares the same lock table, so the commands below filter on this bucket:
```bash
export BUCKET="tofu-state-$(aws sts get-caller-identity --query Account --output text)-<region-code>-<env>"
```

### Remove the State of One Unit

Set the path of the unit in the bucket, which is the path of its directory from `pipelines/` in your catalog fork, or from `live/` in your live fork:
```bash
export UNIT_PATH="<path>" # e.g. dev/eks/stack/.terragrunt-stack/eks/addons/loki/s3/chunks
```

Delete its state file, then its digest:
```bash
aws s3 rm "s3://${BUCKET}/${UNIT_PATH}/tofu.tfstate"
aws dynamodb delete-item \
  --table-name terragrunt_lock_table \
  --key "{\"LockID\": {\"S\": \"${BUCKET}/${UNIT_PATH}/tofu.tfstate-md5\"}}"
```

Then continue at [Check the State Is Gone](#check-the-state-is-gone).

### Remove the State of a Directory of Units

Set the path of the directory in the bucket, without a leading or trailing slash:
```bash
export PREFIX="<path>" # e.g. dev/eks/stack/.terragrunt-stack/eks/addons
```

Delete the state file of every unit under it:
```bash
aws s3 rm "s3://${BUCKET}/${PREFIX}/" --recursive --exclude "*" --include "*/tofu.tfstate"
```

List their digests, and check that every line is under your directory:
```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values "{\":fragment\": {\"S\": \"${BUCKET}/${PREFIX}/\"}}" \
  --query "Items[*].LockID.S" \
  --output text | tr '\t' '\n'
```

Then delete them:
```bash
aws dynamodb scan \
  --table-name terragrunt_lock_table \
  --filter-expression "contains(LockID, :fragment)" \
  --expression-attribute-values "{\":fragment\": {\"S\": \"${BUCKET}/${PREFIX}/\"}}" \
  --query "Items[*].LockID.S" \
  --output text | tr '\t' '\n' | while read -r lock_id; do
    [ -z "$lock_id" ] && continue
    aws dynamodb delete-item \
      --table-name terragrunt_lock_table \
      --key "{\"LockID\": {\"S\": \"$lock_id\"}}"
  done
```

Check that no state file is left. This prints nothing when none is:
```bash
aws s3 ls "s3://${BUCKET}/${PREFIX}/" --recursive | grep "tofu.tfstate$"
```

### Check the State Is Gone

From the directory of a unit whose state you removed, run a plan. It shows every resource as to be created:
```bash
terragrunt plan
```

## A Unit Can't Read Its Unencrypted State

After upgrading to a catalog version that encrypts state, a unit fails with one of:
```text
Error: Backend configuration changed
```
```text
encountered unencrypted payload without unencrypted method configured
```

`root.hcl` now encrypts every state with the KMS key of the `terraform_state_encryption` bootstrap pipeline, both in S3 and in OpenTofu itself. States written before the upgrade are plaintext, and OpenTofu refuses to read them. Migrate them once, pipeline by pipeline.

:::warning
Migrate only when no one else runs Terragrunt against the same states. A run from an older catalog version can't read a migrated state.
:::

First, create the key if it doesn't exist yet, by following [Terraform State Encryption](/docs/quickstart/bootstrap/terraform_state_encryption/).

Then, from the root of your catalog fork, load your environment variables:
```bash
source .env
```

Allow OpenTofu to read plaintext states while it writes encrypted ones. This variable extends the generated encryption configuration with a fallback:
```bash
export TF_ENCRYPTION='method "unencrypted" "migrate" {}
state {
  method = method.aes_gcm.default
  fallback { method = method.unencrypted.migrate }
}
plan {
  method = method.aes_gcm.default
  fallback { method = method.unencrypted.migrate }
}'
```

From the directory of each stack, bootstrap pipelines first, update the backend configuration, then rewrite every state without changing any resource:
```bash
terragrunt stack generate
terragrunt run --all init --non-interactive --no-stack-generate -- -reconfigure
terragrunt run --all apply --non-interactive --no-stack-generate -- -refresh-only -auto-approve
```

`-reconfigure` only updates the local backend configuration. It doesn't copy or move any state.

Once every stack is migrated, remove the fallback:
```bash
unset TF_ENCRYPTION
```

Check that a state is encrypted, replacing `<bucket>` and `<key>`. It prints `encrypted_data` instead of `resources`:
```bash
aws s3 cp "s3://<bucket>/<key>" - | python3 -c 'import json,sys; print(sorted(json.load(sys.stdin)))'
```

The bucket keeps the plaintext versions of the migrated states, since versioning is on. They still hold any secret the states contain, and they're your only rollback path. Delete them once the migration is verified.
