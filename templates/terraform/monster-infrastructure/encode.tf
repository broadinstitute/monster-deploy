module encode {
  source = "/templates/processing-project"
  providers = {
    google.target = google.encode,
    vault.target = vault.target
  }

  project_name = "broad-dsp-monster-encode-${local.env}"
  is_production = var.is_production
  command_center_argo_account_email = module.command_center.encode_argo_runner_email
  region = "us-central1"
  reader_groups = ["clingendevs@broadinstitute.org"] // what is the encode equivalent of this?
  jade_repo_email = local.jade_repo_email
  deletion_age_days = 14
  vault_prefix = "${local.vault_prefix}/processing-projects/encode"
}
