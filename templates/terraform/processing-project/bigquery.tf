resource google_bigquery_dataset dataset {
  provider = google.target
  dataset_id = "monster_staging_data"
  description = "Dataset used by the Monster team for ingest ETL"
  location = "US"
  default_table_expiration_ms = 604800000 # 7 days

  access {
    role = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role = "EDITOR"
    special_group = "projectWriters"
  }
  access {
    role = "READER"
    special_group = "projectReaders"
  }
  access {
    role = "EDITOR"
    user_by_email = var.command_center_argo_account_email
  }
}
