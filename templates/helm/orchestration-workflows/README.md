# Orchestration Workflow Charts
The charts in this directory install the Argo resources (+ associated secrets) required
to run a project's ingest workflows. Each chart should typically pull the `argo-controller`
chart in as a dependency, to prevent projects from stepping on one another.

Argo resources and secrets are installed by rendering local `HelmRelease` resources,
and pushing those to a helm-operator deployment in the target cluster. The operator
then handles running a 2nd round of `helm install` to deploy the referenced charts.

We haven't needed to install special services on a per-project basis yet; if we ever do,
this would be the logical place to put them.
