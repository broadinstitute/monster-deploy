# NOTE: This is needed because CloudSQL doesn't allow DB names to be reused
# within the week that they're deleted, so whenever we want to tear down and
# recreate the instance we need to generate a new name (vs waiting a week).
resource random_id cloudsql_random_id {
  byte_length = 8
}

# Create a single DB instance to back our applications.
# NOTE: We might need multiple instances in prod, if it turns out there's too
# much resource contention sharing a single instance.
resource google_sql_database_instance postgres {
  provider = google.target
  depends_on = [module.enable_services]

  name = "command-center-postgres-${random_id.cloudsql_random_id.hex}"
  database_version = "POSTGRES_9_6"

  settings {
    activation_policy = "ALWAYS"
    pricing_plan = "PER_USE"
    replication_type = "SYNCHRONOUS"
    tier = var.db_tier

    backup_configuration {
      binary_log_enabled = false
      enabled = true
      start_time = "06:00"
    }

    ip_configuration {
      ipv4_enabled = true
      require_ssl = true
      authorized_networks {
        name = "Broad"
        value = "69.173.64.0/18"
      }
    }

    user_labels = {
      app = "command-center"
      role = "database"
      state = "active"
    }
  }
}

# Create an admin account for connecting to the DB using Google's cloudsql-proxy,
# and give it the IAM role it needs to actually connect.
#
# NOTE: The way GCP IAM works, this account can be used for any CloudSQL instance
# in the command-center project. We don't need an account per DB if we end up
# needing multiple DBs.
resource google_service_account cloudsql_proxy_account {
  provider = google.target
  depends_on = [module.enable_services]

  account_id = "cloudsql-proxy-account"
  display_name = "CloudSQL proxy account"
}
# NOTE: SAs created through Terraform are eventually-consistent, so we need to inject
# an arbitrary delay between creating the account and applying IAM rules.
# See: https://www.terraform.io/docs/providers/google/r/google_service_account.html
# And: https://github.com/hashicorp/terraform/issues/17726#issuecomment-377357866
resource null_resource cloudsql_proxy_account_delay {
  provisioner local-exec {
    command = "sleep 10"
  }
  triggers = {
    before = google_service_account.cloudsql_proxy_account.unique_id
  }
}
resource google_project_iam_member cloudsql_proxy_account_iam {
  provider = google.target
  depends_on = [null_resource.cloudsql_proxy_account_delay]

  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.cloudsql_proxy_account.email}"
}

# Create an access key for the account.
resource google_service_account_key cloudsql_proxy_account_key {
  provider = google.target
  service_account_id = google_service_account.cloudsql_proxy_account.name
}

# Store all the info needed to connect to the DB instance in Vault.
resource vault_generic_secret postgres_connection_name {
  provider = vault.target

  path = "${var.vault_prefix}/cloudsql/instance"
  data_json = <<EOT
{
  "name": "${google_sql_database_instance.postgres.name}",
  "connection_name": "${google_sql_database_instance.postgres.connection_name}",
  "proxy_account_key": ${jsonencode(jsonencode(base64decode(google_service_account_key.cloudsql_proxy_account_key.private_key)))}
}
EOT
}
