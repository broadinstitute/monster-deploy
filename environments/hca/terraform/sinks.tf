module dataflow_log_sink {
  source = "github.com/broadinstitute/terraform-shared.git//terraform-modules/gcs_bq_log_sink?ref=sinks-0.0.11"

  providers = {
    google.target      = google.target
    google-beta.target = google-beta.target
  }

  enable_bigquery         = 0
  enable_pubsub           = 0
  enable_gcs              = 1
  owner                   = "monster"
  application_name        = "hca-ingest"
  log_filter              = "resource.type=\"dataflow_step\" severity=ERROR resource.labels.step_id : \"Validate\""
  project                 = local.dev_project_name
}
