# a gcs bucket
resource google_storage_bucket monster_test_bucket {
  provider = google-beta.command-center
  name = "monster-test-bucket"
  location = "US"
}
# a service account
resource google_service_account test_sa {
  provider = google-beta.command-center
  account_id = "monster-dev-test-sa"
  display_name = "test-sa"
}

# a key associated with the service account
resource google_service_account_key test_sa_key {
  service_account_id = google_service_account.test_sa.name
}

# a vault secret containing the JSON key for the service account
resource vault_generic_secret test_secret {
  path = "${local.vault_prefix}/gcs/gcs-transfer-user-key"
  data_json = <<EOT
{
  "sa_key": ${jsonencode(base64decode(google_service_account_key.test_sa_key.private_key))}
}
EOT
}

# NOTE: SAs created through Terraform are eventually-consistent, so we need to inject
# an arbitrary delay between creating the account and applying IAM rules.
# See: https://www.terraform.io/docs/providers/google/r/google_service_account.html
# And: https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource null_resource test-proxy-delay {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "before" = google_service_account.test_sa.unique_id
  }
}

resource google_storage_bucket_iam_member test_iam {
  provider = google-beta.command-center
  bucket = google_storage_bucket.monster_test_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.test_sa.email}"
  depends_on = [null_resource.test-proxy-delay]
}