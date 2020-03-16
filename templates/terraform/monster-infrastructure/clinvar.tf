module clinvar {
  source = "/templates/processing-project"
  providers = {
    google.target = google.clinvar,
    vault.target = vault.target
  }

  project_name = "broad-dsp-monster-clingen-${var.env}"
  is_production = false
  command_center_argo_account_email = module.command_center.clinvar_argo_runner_email
  region = "us-central1"
  reader_groups = ["clingendevs@broadinstitute.org"]
  jade_repo_email = "jade-k8-sa@broad-jade-${var.env}.iam.gserviceaccount.com"
  deletion_age_days = 14
  vault_prefix = "${local.vault_prefix}/processing-projects/clinvar"
}
