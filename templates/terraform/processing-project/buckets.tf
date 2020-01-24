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

# Bucket for temporary data storage.
resource google_storage_bucket staging_storage {
  provider = google.target
  name = "${var.project_name}-staging-storage"
  location = "US"

  dynamic "lifecycle_rule" {
    for_each = var.deletion_age == null ? [] : [var.deletion_age]
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

resource google_storage_bucket_iam_member test_iam {
  # for_each doesn't like lists, so we convert it to a set
  for_each = toset(var.access_emails)

  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # The legacyBucketReader policy seems to be the correct role to have the equivalent of a "Bucket Reader" ACL,
  # as noted here https://cloud.google.com/storage/docs/access-control/iam
  role = "roles/storage.legacyBucketReader"
  member = "user:${each.value}"
}
