resource google_bigquery_dataset dataset {
  provider = google.target
  dataset_id = "monster_staging_data"
  description = "Dataset used by the Monster team for ingest ETL"
  location = "US"
  default_table_expiration_ms = 604800000 # 7 days

  access {
    role = "roles/bigquery.dataEditor"
    user_by_email = var.command_center_argo_account_email
  }
}
