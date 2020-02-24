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

module v2f_writer {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target,
    vault.target = vault.target
  }

  account_id = "v2f-writer"
  display_name = " Service account to write V2F data to GCS"
  vault_path = "${local.vault_prefix}/service-accounts/v2f-writer"
  roles = []
}

resource google_storage_bucket_iam_member v2f_iam {
  provider = google.target
  bucket = "gs://variant-to-function-result-sets"
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${module.v2f_writer.email}"
  depends_on = [module.v2f_writer.delay]
}
