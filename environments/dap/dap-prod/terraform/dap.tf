module dap {
  source               = "../../base"
  project_id           = "exemplary-proxy-308717"
  project_name         = "broad-dsp-monster-dap-prod"
  vault_prefix         = "secret/dsde/monster/prod/dog-aging"
  dagster_runner_email = "monster-dagster-runner@broad-dsp-monster-prod.iam.gserviceaccount.com"
}

terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-prod-terraform-state"
    prefix = "broad-dsp-monster-dap-prod.tfstate.json"
  }
}