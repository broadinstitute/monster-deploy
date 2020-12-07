###
## Store all of our dev state in GCS so we have a single
## source of truth. Need separate state files for each
## environment, and they cannot have variables injected
## into the bucket names. This means they can not be a
## part of the monster-infrastructure module without breaking.
###
terraform {
  backend "gcs" {
    credentials = file("../../gcs_sa_key.json")
    bucket = "broad-dsp-monster-dev-terraform-state"
    path = "tfstate.json"
  }
}
