resource google_bigquery_dataset dataset {
  provider = google.target
  dataset_id = "bigquery-dataset-dev"
  friendly_name = "BigQuery Dev Dataset"
  description = "BigQuery dataset for the Jade Repo"
  location = "US"
  default_table_expiration_ms = 604800000 # 7 days

  access {
    role = "roles/bigquery.dataEditor"
    user_by_email = var.jade_repo_email
  }
  access {
    role = "roles/bigquery.jobUser"
    user_by_email = var.jade_repo_email
  }
}
