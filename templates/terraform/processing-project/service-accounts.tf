module dataflow_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target,
    vault.target = vault.target
  }

  account_id = "dataflow-runner"
  display_name = " Service account to run Dataflow jobs"
  vault_path = "${var.vault_prefix}/service-accounts/dataflow-runner"
  roles = ["dataflow.worker"]
}

# Allow the command-center account to run Dataflow jobs...
resource google_project_iam_member command_center_argo_account_iam {
  provider = google.target
  for_each = toset(["dataflow.developer", "compute.viewer", "bigquery.jobUser"])

  role = "roles/${each.value}"
  member = "serviceAccount:${var.command_center_argo_account_email}"
}
# ... and allow it to do so as the dataflow-runner service account.
resource google_service_account_iam_binding dataflow_runner_user_binding {
  provider = google.target

  service_account_id = module.dataflow_runner_account.id
  role = "roles/iam.serviceAccountUser"
  members = ["serviceAccount:${var.command_center_argo_account_email}"]
}
