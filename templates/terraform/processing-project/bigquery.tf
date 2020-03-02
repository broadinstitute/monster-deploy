resource google_bigquery_dataset dataset {
  provider = google.target
  dataset_id = "bigquery-dataset-dev"
  friendly_name = "BigQuery Dev Dataset"
  description = "BigQuery development dataset"
  location = "US"
  default_table_expiration_ms = 604800000 # 7 days

  access {
    role = "roles/bigquery.dataEditor"
    user_by_email = var.command_center_argo_account_email
  }
  access {
    role = "roles/bigquery.jobUser"
    user_by_email = var.command_center_argo_account_email
  }
}
