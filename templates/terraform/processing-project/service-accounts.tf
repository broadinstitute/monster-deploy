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

module dataflow_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = "dataflow-runner"
  display_name = " Service account to run Dataflow jobs"
  vault_path = "${var.vault_prefix}/service-accounts/dataflow-runner"
  roles = ["dataflow.worker"]
}

module dataflow_launcher_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = "dataflow-launcher"
  display_name = " Service account to launch Dataflow jobs"
  vault_path = "${var.vault_prefix}/service-accounts/dataflow-launcher"
  roles = ["dataflow.developer", "compute.viewer"]
}

module artifact_uploader_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = "artifact-uploader"
  display_name = " Service account to upload artifacts to GCS"
  vault_path = "${var.vault_prefix}/service-accounts/artifact-uploader"
  roles = []
}
