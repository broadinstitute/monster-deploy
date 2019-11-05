###
## Store all of our state in GCS so we have a single
## source of truth.
###
terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-dev-terraform-state"
    path = "dev.tfstate.json"
  }
}
