# Argo Controller Chart
This Helm chart installs an Argo controller (+ any required Vault secrets) into
a namespace. It's intended to be pulled in as a local dependency by other charts
under the `orchestration-workflows/` template directory, as it requires inputs
that vary on a per-env/per-project basis.

The controller and secrets are installed by rendering local `HelmRelease` resources,
and pushing those to a helm-operator deployment in the target cluster. The operator
then handles running a 2nd round of `helm install` to deploy the referenced charts.
