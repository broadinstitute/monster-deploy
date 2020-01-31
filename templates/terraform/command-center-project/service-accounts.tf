module command_center_service_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = var.service_account_id
  display_name = "Service account to run GKE system pods"
  vault_path = "${var.vault_prefix}/gcs/sa-key"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}
