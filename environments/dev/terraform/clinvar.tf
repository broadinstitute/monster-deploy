provider google-beta {
  project = "broad-dsp-monster-clingen-dev"
  region = "us-central1"
  alias = "clinvar"
}

module clinvar {
  source = "/templates/processing-project"
  providers = {
    google.target = google-beta.clinvar,
    vault.target = vault.command-center
  }

  project_name = "broad-dsp-monster-clingen-dev"
  is_production = false
  command_center_argo_account_email = module.command_center.clinvar_argo_runner_email
  region = "us-central1"
  k8s_zone = "a"
  k8s_scaled_cluster_max_size = 3
  k8s_scaled_machine_type = "n1-standard-1"
  k8s_static_cluster_size = 2
  reader_groups = ["clingendevs@broadinstitute.org"]
  jade_repo_email = "jade-k8-sa@broad-jade-dev.iam.gserviceaccount.com"
  deletion_age_days = null # FIXME: Reset back to 30 after we set up prod.
  vault_prefix = "${local.vault_prefix}/processing-projects/clinvar"
}
