terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-dev-terraform-state"
    path = "hca.tfstate.json"
  }
}
