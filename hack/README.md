# Hack
This directory contains the scripts that actually drive deployments. The scripts
are broken down to (hopefully) separate pieces of infrastructure that iterate at
significantly different speeds (i.e. Terraform modules vs. Helm releases).

## Setting up a fresh environment
If nothing's been set up yet, run the scripts in this order:
1. `apply-terraform <env>`
2. `apply-base-cluster-resources <env>`
2. `apply-command-center-releases <env>`

## Why are there no teardown scripts?
Explicit destroys are dangerous. Terraform especially can remove resources that can
never be exactly re-created (i.e. service account IDs can't be reused). We may add
teardown scripts for GKE resources if the need comes up often enough.
