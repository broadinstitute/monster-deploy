# CRD Operators Chart
This Helm chart installs the baseline operator deployments needed to install any of our other templates.
These include:
1. The FluxCD helm-operator
2. The secrets-manager

The helm-operator is installed as a chart dependency. The secrets-manager is then installed by the
helm-operator, after this chart renders & POSTs a `HelmRelease` resource for the deployment.

## Order of Operations
This chart must be fully applied to a cluster before any of our other templates. If it isn't, then
it's possible for the system to enter a deadlock. This is because the helm-operator has an internal
queue + a max-concurrency parameter. If the secrets-manager is enqueued after enough releases that
depend on Vault secrets, max concurrency can be reached by releases that are waiting on Vault secrets
that will never appear.
