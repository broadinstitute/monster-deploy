# a gcs bucket
resource google_storage_bucket monster_test_bucket {
  provider = google-beta.command-center
  name = "monster-test-bucket"
  location = "US"
}

module test_sa {
  source = "./templates/google-sa"
  providers = {
    google.target = google-beta.command-center,
    vault.target = vault.command-center
  }

  account_id = "monster-dev-test-sa"
  display_name = "test-sa"
  vault_path = "${local.vault_prefix}/gcs/gcs-transfer-user-key"
}

resource google_storage_bucket_iam_member test_iam {
  provider = google-beta.command-center
  bucket = google_storage_bucket.monster_test_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.test_sa.email}"
  depends_on = [module.test_sa.delay]
}
