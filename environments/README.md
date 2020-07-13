# Monster Environments
This directory contains concrete definitions of the "always-on" infrastructure
that runs within Monster's environments. These definitions are expected to be
relatively stable, and not run all that often.

## Environment components
Environment definitions consist of:
1. A single Terraform module
2. A set of k8s namespaces and API extensions
3. A Helm chart

Most of the "business logic" for these two pieces is tracked elsewhere, either in
the [templates](../templates) directory or in entirely separate git repositories.

## Environments
Our original intent was to maintain two environments: dev and prod. However, we've
found that sharing infrastructure across ingest projects causes more headaches than
it's worth, so we've begun to spin off new environments as needed.

### Dev
Our dev environment serves as both:
1. A mirror of production, but running the latest versions of our workflows, and
2. A host for services/infrastructure needed to run tests

The general "shape" of hardware in dev is meant to mimic prod, but machines are
be less finely-tuned in general.

### Prod
Our prod environment runs the software required to deliver data into the
production data repository.

### V2F Prod
Our V2F-prod environment is only deployed sporadically, to handle ad-hoc ingest requests
from that project.

### HCA
Our HCA environment currently spans both "dev" and "prod" infrastructure. It will likely
need to split in two once we move past the MVP stage of the project.

## Deploying an environment
Environments are set up in stages.
1. Run `hack/apply-terraform <env>` to set up infrastructure. You'll be prompted to
   confirm the Terraform plan.
2. Run `hack/apply-base-cluster-resources <env>` to install basic CRDs and operators into
   the GKE cluster created via Terraform.
3. Run `hack/apply-command-center-resources <env>` to install additional CRDs and singleton
   services into a GKE cluster that should serve as an ingest "command center".
4. Run `hack/apply-orchestration-workflow <env> <workflow-name>` to install services and Argo
   resources into a command-center cluster. The `workflow-name` used in this case must be a
   directory nested under `environments/<env>/helm/orchestration-workflows/`.

## Destroying an environment
DON'T DO THIS. Some pieces of our environment require manual intervention from external
teams (i.e. BITS). Instead, update/delete pieces of the environment definition that
we no longer want to run, and re-initialize it.
