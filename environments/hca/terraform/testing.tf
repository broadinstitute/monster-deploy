// create test bucket
resource google_storage_bucket test_bucket {
  provider = google-beta.target
  name     = "${local.dev_project_name}-test-storage"
  location = "US"
}

resource google_storage_bucket_iam_member test_bucket_iam {
  provider = google-beta.target
  bucket   = google_storage_bucket.test_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.hca_test_account.email}"
  depends_on = [module.hca_test_account.delay]
}


module hca_test_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target  = vault.target
  }

  account_id   = "hca-test-runner"
  display_name = "Service account to run HCA tests"
  vault_path   = "${local.dev_vault_prefix}/service-accounts/hca-test-runner"
  roles        = ["dataflow.worker", "dataflow.admin",  "bigquery.jobUser", "bigquery.dataOwner"]
}
