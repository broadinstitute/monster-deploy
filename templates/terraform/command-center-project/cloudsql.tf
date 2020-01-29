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

module test_sa {
  source = "/templates/google-sa"

  account_id = "cloudsql-proxy-account"
  display_name = "CloudSQL proxy account"
  vault_path = "${var.vault_prefix}/gcs/gcs-transfer-user-key"
  roles = ["roles/cloudsql.client"]
}


# TODO does the secret below need the proxy_account_key too, or is it fine to store
# it where we have already stored it in the service account module? If it is needed
# below, we have to expose the private_key as an output for the above module

# Store all the info needed to connect to the DB instance in Vault.
resource vault_generic_secret postgres_connection_name {
  provider = vault.target

  path = "${var.vault_prefix}/cloudsql/instance"
  data_json = <<EOT
{
  "name": "${google_sql_database_instance.postgres.name}",
  "region": "${google_sql_database_instance.postgres.region}",
  "project": "${google_sql_database_instance.postgres.project}",
  "connection_name": "${google_sql_database_instance.postgres.connection_name}",
  "proxy_account_key": ${jsonencode(base64decode(google_service_account_key.cloudsql_proxy_account_key.private_key))}
}
EOT
}
