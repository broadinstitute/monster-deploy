###
## Store all of our state in GCS so we have a single
## source of truth.
###
terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-${var.env}-terraform-state"
    path = "tfstate.json"
  }
}
