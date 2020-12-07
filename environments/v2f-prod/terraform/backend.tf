###
## Store all of our state in GCS so we have a single
## source of truth.
###
terraform {
  backend "gcs" {
    credentials = file("../../gcs_sa_key.json")
    bucket = "broad-dsp-monster-prod-terraform-state"
    path = "v2f.tfstate.json"
  }
}
