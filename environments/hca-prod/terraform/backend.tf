terraform {
  backend "gcs" {
    credentials = file("../../gcs_sa_key.json")
    bucket = "broad-dsp-monster-prod-terraform-state"
    path = "hca.tfstate.json"
  }
}
