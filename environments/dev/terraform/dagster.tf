module dagster_runner_service_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google.command-center,
    vault.target  = vault.command-center
  }

  account_id   = "monster-dagster-runner"
  display_name = "Service account to run Dagster pipelines."
  vault_path   = "${local.vault_prefix}/service-accounts/dagster-runner"
  roles = [
    "dataflow.developer",
    "compute.viewer",
    "bigquery.jobUser",
    "bigquery.dataOwner",
  ]
}

resource google_service_account_iam_binding kubernetes_role_binding {
  provider = google.command-center

  service_account_id = module.dagster_runner_service_account.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.dev_project_name}.svc.id.goog[dagster/monster-dagster]"
  ]
}