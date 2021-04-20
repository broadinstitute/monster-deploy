variable service_ids {
  type        = list(string)
  description = "IDs of Google APIs to enable in the target project."
}

output standard_service_ids {
  value = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "runtimeconfig.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "dataflow.googleapis.com",
    "storagetransfer.googleapis.com",
    "pubsub.googleapis.com"
  ]
}
