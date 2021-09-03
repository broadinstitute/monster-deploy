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

# Bucket for storing intermediate results from Dagster pipeline runs.
resource google_storage_bucket dev_dagster_storage {
  provider = google.command-center
  name     = "${local.dev_project_name}-dagster-storage"
  location = "US"

  # delete intermediate results after four weeks
  lifecycle_rule {
    condition {
      age = 28
    }

    action {
      type = "Delete"
    }
  }
}

resource google_storage_bucket_iam_member dev_dagster_run_bucket_iam {
  provider = google.command-center
  bucket   = google_storage_bucket.dev_dagster_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.dagster_runner_service_account.email}"
}