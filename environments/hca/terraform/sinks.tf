resource google_storage_bucket logs {
  provider = google.target
  name     = "${local.dev_project_name}-error-logs"
}

# Grant service account access to the storage bucket
resource "google_storage_bucket_iam_member" "bucket-log-writer" {
  provider   = google.target
  bucket     = google_storage_bucket.logs.name
  role       = "roles/storage.objectCreator"
  member     = google_logging_project_sink.bucket-log-sink.writer_identity
  depends_on = [google_storage_bucket.logs]
}

resource "google_logging_project_sink" "bucket-log-sink" {
  provider               = google.target
  name                   = "${local.dev_project_name}-gcs-log-sink"
  destination            = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter                 = "resource.type=\"dataflow_step\" severity=ERROR jsonPayload.message : (\"SchemaValidationError\" OR \"FileMismatchError\" OR \"NoRegexPatternMatchError\" OR \"MissingPropertyError\")"
  unique_writer_identity = true
  depends_on             = [google_storage_bucket.logs]
}
