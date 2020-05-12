# temp bucket for dataflow temporary files
resource google_storage_bucket temp_bucket {
  provider = google.target
  name = "${local.project_name}-temp-storage"
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
  bucket = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_temp_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

# test input source bucket
resource google_storage_bucket input_storage {
  provider = google.target
  name = "${local.project_name}-input-storage"
  location = "US"
}

resource google_storage_bucket_iam_member input_bucket_runner_iam {
  provider = google.target
  bucket = google_storage_bucket.input_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_input_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.input_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

# staging bucket
resource google_storage_bucket staging_storage {
  provider = google.target
  name = "${local.project_name}-staging-storage"
  location = "US"
}

resource google_storage_bucket_iam_member staging_bucket_runner_iam {
  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_staging_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

resource google_storage_bucket_iam_member staging_account_iam_reader {
  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${local.jade_repo_email}"
}

# Bucket for long term Argo logs storage, currently want no "delete after N days" rule.
resource google_storage_bucket hca_argo_archive {
  provider = google.target
  name = "${local.project_name}-argo-archive"
  location = "US"
}

resource google_storage_bucket_iam_member hca_argo_logs_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.hca_argo_archive.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}
