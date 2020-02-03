# a service account
resource google_service_account sa {
  provider = google.target
  account_id = var.account_id
  display_name = var.display_name
  depends_on = [var.dependencies]
}

# a key associated with the service account
resource google_service_account_key sa_key {
  provider = google.target
  service_account_id = google_service_account.sa.name
}

# a vault secret containing the JSON key for the service account
resource vault_generic_secret sa_secret {
  provider = vault.target
  path = var.vault_path
  data_json = <<EOT
{
  "key": ${jsonencode(base64decode(google_service_account_key.sa_key.private_key))}
}
EOT
}

# NOTE: SAs created through Terraform are eventually-consistent, so we need to inject
# an arbitrary delay between creating the account and applying IAM rules.
# See: https://www.terraform.io/docs/providers/google/r/google_service_account.html
# And: https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource null_resource sa_delay {
  provisioner "local-exec" {
    command = "sleep 10"
  }
  triggers = {
    "before" = google_service_account.sa.unique_id
  }
}

resource google_project_iam_member sa_iam {
  for_each = toset(var.roles)

  provider = google.target
  depends_on = [null_resource.sa_delay]

  role = each.value
  member = "serviceAccount:${google_service_account.sa.email}"
}
