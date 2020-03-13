provider google-beta {
  project = "broad-dsp-monster-clingen-${var.env}"
  region = "us-central1"
  alias = "clinvar"
}

# TODO I changed the jade_repo_email to switch on the environment, not sure if this is right
module clinvar {
  source = "/templates/processing-project"
  providers = {
    google.target = google-beta.clinvar,
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
