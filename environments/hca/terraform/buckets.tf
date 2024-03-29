# temp bucket for dataflow temporary files
resource google_storage_bucket temp_bucket {
  provider = google.target
  name     = "${local.dev_project_name}-temp-storage"
  location = "US"

  lifecycle_rule {
    action {
      type = "Delete"
    }

    # Delete files after they've been in the bucket for 7 days.
    condition {
      age = 7
    }
  }
}

resource google_storage_bucket_iam_member temp_bucket_runner_iam {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member temp_bucket_test_iam {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.hca_test_account.email}"
  depends_on = [module.hca_test_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_temp_bucket_iam {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

# staging bucket
resource google_storage_bucket staging_storage {
  provider = google.target
  name     = "${local.dev_project_name}-staging-storage"
  location = "US"
}

# staging bucket (us-central1)
resource google_storage_bucket staging_storage_uc1 {
  provider = google.target
  name     = "${local.dev_project_name}-staging-storage-uc1"
  location = "us-central1"
}

resource google_storage_bucket_iam_member staging_bucket_runner_iam {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member staging_uc1_bucket_runner_iam {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage_uc1.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}


resource google_storage_bucket_iam_member hca_argo_staging_bucket_iam {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

resource google_storage_bucket_iam_member staging_account_iam_reader {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.dev_repo_email}"
}

resource google_storage_bucket_iam_member staging_uc1_account_iam_reader {
  provider = google.target
  bucket   = google_storage_bucket.staging_storage_uc1.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.dev_repo_email}"
}

# Bucket for long term Argo logs storage, currently want no "delete after N days" rule.
resource google_storage_bucket hca_argo_archive {
  provider = google.target
  name     = "${local.dev_project_name}-argo-archive"
  location = "US"
}

resource google_storage_bucket_iam_member hca_argo_logs_bucket_iam {
  provider = google.target
  bucket   = google_storage_bucket.hca_argo_archive.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}
# Service accounts that use these buckets
# sa w/permissions to use dataflow & bigquery
module hca_dataflow_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google.target,
    vault.target  = vault.target
  }

  account_id   = "hca-dataflow-runner"
  display_name = "Service account to run HCA dataflow jobs"
  vault_path   = "${local.dev_vault_prefix}/service-accounts/hca-dataflow-runner"
  roles        = ["dataflow.worker"]
}

module hca_argo_runner_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google.target,
    vault.target  = vault.target
  }

  account_id   = "hca-argo-runner"
  display_name = "Service account to run HCA's Argo workflow."
  vault_path   = "${local.dev_vault_prefix}/service-accounts/hca-argo-runner"
  roles        = ["dataflow.developer", "compute.viewer", "bigquery.jobUser", "bigquery.dataOwner"]
}

data google_project current_project {
  provider = google.target
}

resource google_service_account_iam_binding hca_workload_identity_binding {
  provider = google.target

  service_account_id = module.hca_argo_runner_account.id
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${data.google_project.current_project.name}.svc.id.goog[hca-mvp/argo-runner]"]
}

resource google_service_account_iam_binding dataflow_runner_user_binding {
  provider = google.target

  service_account_id = module.hca_dataflow_account.id
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${module.hca_argo_runner_account.email}",
    "serviceAccount:${module.hca_dagster_runner_account.email}"
  ]
}
