###
## Store all of our state in GCS so we have a single
## source of truth.
###
terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-prod-terraform-state"
    path = "v2f.json"
  }
}
