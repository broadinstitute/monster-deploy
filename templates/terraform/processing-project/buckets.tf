# Bucket for temp files used by processing programs.
resource google_storage_bucket temp_bucket {
  provider = google.target
  name = "${var.project_name}-temp-storage"
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
  member = "serviceAccount:${module.dataflow_runner_account.email}"
  depends_on = [module.dataflow_runner_account.delay]
}

# Bucket for temporary data storage.
resource google_storage_bucket staging_storage {
  provider = google.target
  name = "${var.project_name}-staging-storage"
  location = "US"

  dynamic "lifecycle_rule" {
    for_each = var.deletion_age_days == null ? [] : [var.deletion_age_days]
    content {
      action {
        type = "Delete"
      }
      condition {
        age = lifecycle_rule.value
      }
    }
  }
}

resource google_storage_bucket_iam_member staging_bucket_runner_iam {
  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.dataflow_runner_account.email}"
  depends_on = [module.dataflow_runner_account.delay]
}

resource google_storage_bucket_iam_member staging_iam_reader {
  # for_each doesn't like lists, so we convert it to a set
  for_each = toset(var.reader_groups)

  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role = "roles/storage.objectViewer"
  member = "group:${each.value}"
}

resource google_storage_bucket_iam_member command_center_argo_staging_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${var.command_center_argo_account_email}"
}

resource google_storage_bucket_iam_member command_center_argo_temp_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${var.command_center_argo_account_email}"
}

resource google_storage_bucket_iam_member staging_account_iam_reader {
  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${var.jade_repo_email}"
}

# Bucket for long term Argo logs storage, currently want no "delete after N days" rule.
resource google_storage_bucket argo_logs_storage {
  provider = google.target
  name = "${var.project_name}-argo-logs-storage"
  location = "US"
}

resource google_storage_bucket_iam_member command_center_argo_logs_bucket_iam {
  provider = google.target
  bucket =  google_storage_bucket.argo_logs_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${var.command_center_argo_account_email}"
}
