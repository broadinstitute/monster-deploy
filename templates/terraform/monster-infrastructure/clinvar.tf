module clinvar {
  source = "../processing-project"
  providers = {
    google.target = google.clinvar,
    vault.target  = vault.target
  }

  project_name                      = "broad-dsp-monster-clingen-${local.env}"
  is_production                     = var.is_production
  command_center_argo_account_email = module.command_center.clinvar_argo_runner_email
  region                            = "us-central1"
  create_results_bucket             = true
  result_reader_groups              = ["clingendevs@broadinstitute.org"]
  jade_repo_email                   = local.jade_repo_email
  deletion_age_days                 = 14
  vault_prefix                      = "${local.vault_prefix}/processing-projects/clinvar"
}
