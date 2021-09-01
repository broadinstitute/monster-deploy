module dap {
  source               = "../../base"
  project_id           = "broad-dsp-monster-dap-dev"
  project_name         = "broad-dsp-monster-dap-dev"
  vault_prefix         = "secret/dsde/monster/dev/dog-aging"
  dagster_runner_email = ""
}

terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-dev-terraform-state"
    prefix = "broad-dsp-monster-dap-dev.tfstate.json"
  }
}
