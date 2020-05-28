# Staging bucket for EBI.
resource google_storage_bucket ebi_staging_bucket {
  provider = google-beta.target
  name = "${local.dev_project_name}-ebi-staging"
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
  vault_path = "${local.dev_vault_prefix}/service-accounts/ebi-storage-writer"
  roles = []
}

# Make sure EBI is an admin on their bucket.
resource google_storage_bucket_iam_member ebi_writer_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ebi_staging_bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${module.ebi_writer_account.email}"
}

# Make sure both TDRs can read from the bucket.
resource google_storage_bucket_iam_member tdr_reader_iam {
  provider = google-beta.target
  for_each = toset([local.dev_repo_email, local.prod_repo_email])

  bucket = google_storage_bucket.ebi_staging_bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${each.value}"
}
