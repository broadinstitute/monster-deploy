module processing_gke_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = "processing-gke-runner"
  display_name = "Service account to run GKE system pods"
  vault_path = "${var.vault_prefix}/service-accounts/gke-runner"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}