terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-prod-terraform-state"
    path   = "hca.tfstate.json"
  }
}
