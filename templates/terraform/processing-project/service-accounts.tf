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

resource google_project_iam_member command_center_argo_account_iam {
  for_each = toset(["dataflow.developer", "compute.viewer"])

  provider = google.target
  role = "roles/${each.value}"
  member = "serviceAccount:${var.command_center_argo_account_email}"
}
