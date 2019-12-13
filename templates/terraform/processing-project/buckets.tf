resource google_storage_bucket artifact_bucket {
  provider = google.target
  name = "${var.project_name}-artifact-storage"
  location = "US"
}

resource google_storage_bucket staging_storage {
  provider = google.target
  name = "${var.project_name}-staging-storage"
  location = "US"

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = 30
    }
  }
}
