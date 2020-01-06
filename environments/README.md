# Monster Environments

This directory contains concrete definitions of the "always-on" infrastructure
that runs within Monster's environments. These definitions are expected to be
relatively stable, and not run all that often.

## Environment Components

Environment definitions consist of:
1. A single Terraform module
2. A deployment of Flux CD's Helm Operator
2. (TODO) A single Helm chart to push HelmRelease specs to the operator

Most of the "business logic" for these two pieces is tracked elsewhere, either in
the [templates](../templates) directory or in entirely separate git repositories.

## Environments

As of Q4 2019, we only intend to maintain two environments.

### Dev

Our dev environment will serve as both:
1. A mirror of production, but running the latest versions of our workflows, and
2. A host for services/infrastructure needed to run tests

The general "shape" of hardware in dev is meant to mimic prod, but machines will
be less powerful in general.

### Prod

Our prod environment will run the software required to deliver data into the
production data repository.

## Deploying an Environment

Run `./init.sh <env>`. If anything new needs to be set up, you'll be prompted to
confirm the Terraform plan.

## Destroying an Environment

DON'T DO THIS. Some pieces of our environment require manual intervention from external
teams (i.e. BITS). Instead, update/delete pieces of the environment definition that
we no longer want to run, and re-initialize it.
