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
# TODO: Add an IAM resource which allows the repo to read from this.
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
