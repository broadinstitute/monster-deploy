terraform {
  backend "gcs" {
    credentials = "../../gcs_sa_key.json"
    bucket = "broad-dsp-monster-dev-terraform-state"
    path = "hca.tfstate.json"
  }
}
