resource google_bigquery_dataset dataset {
  provider = google.target
  dataset_id = "monster_staging_data"
  description = "Dataset used by the Monster team for ingest ETL"
  location = "US"
  default_table_expiration_ms = 604800000 # 7 days

  # Apparently these aren't automatically applied.
  # If we don't set the owner in particular, whoever happens to
  # apply the TF will be automatically assigned OWNER permissions.
  access {
    role = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role = "READER"
    special_group = "projectReaders"
  }

  # Make sure the processing SA can generate data.
  access {
    role = "WRITER"
    user_by_email = var.command_center_argo_account_email
  }
}
