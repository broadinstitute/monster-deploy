# Bucket for storing project-specific artifacts (i.e. Dataflow jars).
resource google_storage_bucket artifact_bucket {
  provider = google.target
  name = "${var.project_name}-artifact-storage"
  location = "US"
}

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
  bucket = google_storage_bucket.temp_bucket.name
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
  # The legacyBucketReader policy seems to be the correct role to have the equivalent of a "Bucket Reader" ACL,
  # as noted here https://cloud.google.com/storage/docs/access-control/iam
  role = "roles/storage.legacyBucketReader"
  member = "group:${each.value}"
}
