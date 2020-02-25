module command_center_gke_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target,
    vault.target = vault.target
  }

  account_id = "command-center-gke-runner"
  display_name = "Service account to run GKE system pods"
  vault_path = "${local.vault_prefix}/service-accounts/gke-runner"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}
