# Hack

This directory contains the scripts that actually drive deployments. The scripts
are broken down to (hopefully) separate pieces of infrastructure that iterate at
significantly different speeds (i.e. Terraform modules vs. Helm releases).

## Setting up a fresh environment
If nothing's been set up yet, run the scripts in this order:
1. `apply-terraform <env>`
2. `init-environment.sh <env>` # Will be broken down further in following PRs
