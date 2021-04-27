resource google_project_iam_custom_role argo_access {
  provider = google.target

  role_id     = "argoworkflows.user"
  title       = "Argo Workflows API User"
  description = "Ability to interact with the REST API exposed by a Kubernetes cluster running Argo Workflows UI."
  permissions = [
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.list",
    "container.thirdPartyObjects.update",
  ]
}

module hca_dagster_runner_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google.target,
    vault.target  = vault.target
  }

  account_id   = "hca-dagster-runner"
  display_name = "Service account to run HCA's Dagster pipelines."
  vault_path   = "${local.prod_vault_prefix}/service-accounts/hca-dagster-runner"
  roles = [
    "dataflow.developer",
    "compute.viewer",
    "bigquery.jobUser",
    "bigquery.dataOwner"
  ]
}

resource google_project_iam_member argo_access_member {
  provider = google.target

  role   = google_project_iam_custom_role.argo_access.id
  member = "serviceAccount:${module.hca_dagster_runner_account.email}"
}

resource google_service_account_iam_binding kubernetes_role_binding {
  provider = google.target

  service_account_id = module.hca_dagster_runner_account.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.prod_project_id}.svc.id.goog[dagster/monster-dagster]"
  ]
}

resource google_storage_bucket_iam_member hca_dagster_staging_bucket_iam {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dagster_runner_account.email}"
}

resource google_storage_bucket_iam_member hca_dagster_temp_bucket_iam {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dagster_runner_account.email}"
}

resource google_service_account_iam_binding dataflow_runner_dagster_user_binding {
  provider = google.target

  service_account_id = module.hca_dataflow_account.id
  role               = "roles/iam.serviceAccountUser"
  members            = ["serviceAccount:${module.hca_dagster_runner_account.email}"]
}
