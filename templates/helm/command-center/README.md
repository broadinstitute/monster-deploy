# Command-Center Chart
This Helm chart installs singleton services (+ any required Vault secrets) needed to
run a Monster "command-center". These include:
1. The cloudsql-proxy
2. The Argo server / UI
3. The Prometheus operator

The chart installs each of these services by rendering & POST-ing `HelmRelease` resources
into the target cluster. A helm-operator instance must be running in the cluster to receive
those resources and convert them to actual deployments.
