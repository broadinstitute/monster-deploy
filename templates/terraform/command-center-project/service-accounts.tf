module test_sa {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = var.service_account_name
  display_name = "Service Account to run GKE system pods"
  vault_path = "${var.vault_prefix}/gcs/sa-key"
  roles = ["logging.logWriter", "monitoring.metricWriter", "monitoring.viewer"]
}