# Enable baseline APIs needed to use Terraform at all.
resource google_project_service service_usage {
  provider = google.target
  service = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource google_project_service cloud_resource_manager {
  provider = google.target
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource google_project_service services {
  provider = google.target
  count = length(var.service_ids)
  service = var.service_ids[count.index]
  depends_on = [
    google_project_service.service_usage,
    google_project_service.cloud_resource_manager
  ]
}
