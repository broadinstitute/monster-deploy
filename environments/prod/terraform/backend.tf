###
## Store all of our prod state in GCS so we have a single
## source of truth. Need separate state files for each
## environment, and they cannot have variables injected
## into the bucket names. This means they can not be a
## part of the monster-infrastructure module without breaking.
###
terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-prod-terraform-state"
    path   = "tfstate.json"
  }
}
