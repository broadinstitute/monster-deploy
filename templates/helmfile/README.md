This directory contains [helmfiles](https://github.com/roboll/helmfile) that we're leveraging to install and update
Dagster clusters in our common infrastructure.

To install, connect to the K8S cluster to be updated and run this command:

```
ENV=<dev|prod> helmfile --interactive --file monster_comand_center_dagster.yaml apply
```