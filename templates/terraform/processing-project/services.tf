module enable_services {
  source = "/templates/api-services"
  providers = {
    google.target = google.target
  }
  service_ids = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "dataflow.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "runtimeconfig.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com"
  ]
}
