# Staging bucket for EBI.
resource google_storage_bucket ebi_staging_bucket {
  provider = google-beta.target
  name = "${local.prod_project_name}-ebi-staging"
  location = "US"
}

# Service account for EBI to use when writing to the bucket.
module ebi_writer_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "ebi-staging-writer"
  display_name = "Account used by EBI to interact with their staging bucket"
  vault_path = "${local.prod_vault_prefix}/service-accounts/ebi-storage-writer"
  roles = ["storagetransfer.user", "storagetransfer.viewer"]
}

# EBI is an admin on their bucket.
resource google_storage_bucket_iam_member ebi_writer_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ebi_staging_bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.ebi_writer_account.email}"
}

# Both TDRs and our Dataflow SA can read from the bucket.
resource google_storage_bucket_iam_member tdr_reader_iam {
  provider = google-beta.target
  for_each = toset([local.prod_repo_email, local.prod_repo_email, module.hca_dataflow_account.email])

  bucket = google_storage_bucket.ebi_staging_bucket.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${each.value}"
}

# Google's Storage Transfer Service can interact with the bucket.
data google_storage_transfer_project_service_account sts_account {
  provider = google-beta.target
}

resource google_storage_bucket_iam_member sts_iam {
  provider = google-beta.target

  bucket = google_storage_bucket.ebi_staging_bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_storage_transfer_project_service_account.sts_account.email}"
}
