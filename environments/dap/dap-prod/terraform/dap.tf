module dap {
  source       = "../../base"
  project_id   = "exemplary-proxy-308717"
  project_name = "broad-dsp-monster-dap-prod"
}

terraform {
  backend "gcs" {
    bucket = "broad-dsp-monster-prod-terraform-state"
    prefix = "broad-dsp-monster-dap-prod.tfstate.json"
  }
}
