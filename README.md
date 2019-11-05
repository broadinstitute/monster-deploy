# dsp-monster-core-infrastructure
Infrastructure-as-code for Monster team's "core" environments

## Deploying an environment
We're keeping things simple for now.

1. Install Terraform with `brew install terraform`
2. Navigate to the environment you want to deploy (i.e. `cd environments/dev/terraform`)
3. Initialize Terraform with `terraform init`
4. Run Terraform with `terraform apply`

## Tearing down an environment
Don't do this. If you need to change something, update the TF files and re-apply.
