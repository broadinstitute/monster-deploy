resource google_storage_bucket storage_bucket {
  location = "us-central1"
  name     = "${var.project_name}-storage"
  project  = var.project_name
}
