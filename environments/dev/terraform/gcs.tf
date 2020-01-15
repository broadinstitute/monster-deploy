provider google {
  alias = "target"
}

# a gcs bucket
resource google_storage_bucket test_bucket {
  provider = google.target
  name = "PLACEHOLDER"
  location = "US"
}
# a service account
resource google_service_account test_sa {
  account_id = "monster-dev-test-sa"
  display_name = "test-sa"
  depends_on = []
}

# a key associated with the service account
resource google_service_account_key test_sa_key {
  service_account_id = google_service_account.test_sa.name
}

# a vault secret containing the JSON key for the service account
resource vault_generic_secret test_secret {
  path = "secret/dsde/monster/dev/gcs/SOMETHINGSOMETHING"
  data_json = base64decode(google_service_account_key.test_sa_key.private_key)
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

# iam bindings to allow service account to read/write on bucket
resource google_project_iam_member test_iam {
  project = "PLACEHOLDER"
  role = "PLACEHOLDER"
  member = "PLACEHOLDER"
  depends_on = [null_resource.test-proxy-delay]
}
