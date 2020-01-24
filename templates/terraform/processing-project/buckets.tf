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

  lifecycle_rule {
    action {
      type = "Delete"
    }

    # Delete files after they've been in the bucket for 30 days.
    condition {
      age = 30
    }
  }
}

resource google_storage_bucket_iam_member test_iam {

  for_each = toset(var.access_emails)

  provider = google.target
  bucket = google_storage_bucket.staging_storage.name
  # The legacyBucketReader policy seems to be the correct role to have the equivalent of a "Bucket Reader" ACL,
  # as noted here https://cloud.google.com/storage/docs/access-control/iam
  role = "roles/storage.legacyBucketReader"
  member = "user:${each.value}"
}
