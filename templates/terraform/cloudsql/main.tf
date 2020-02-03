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
  depends_on = [var.dependencies]

  name = "${var.name_prefix}-postgres-${random_id.cloudsql_random_id.hex}"
  database_version = var.postgres_version

  settings {
    activation_policy = "ALWAYS"
    pricing_plan = "PER_USE"
    replication_type = "SYNCHRONOUS"
    tier = "db-custom-${var.cpu}-${var.ram}"
    user_labels = var.labels

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
  }
}

resource random_id db-password {
  for_each = toset(var.user_names)

  byte_length = 16
}

resource google_sql_user db-user {
  for_each = toset(var.user_names)

  provider = google.target
  name = "${var.name_prefix}-${each.value}"
  password = random_id.db-password[each.value].hex
  instance = google_sql_database_instance.postgres.name
}

resource google_sql_database db {
  for_each = toset(var.db_names)

  provider = google.target
  name = "${var.name_prefix}-${each.value}"
  instance = google_sql_database_instance.postgres.name
  charset = "UTF8"
  collation = "en_US.UTF8"
  depends_on = [google_sql_user.db-user]
}

# Store info needed to connect to the DB instance in Vault.
resource vault_generic_secret postgres_connection_name {
  provider = vault.target

  path = "${var.vault_prefix}/cloudsql/instance"
  data_json = <<EOT
{
  "name": "${google_sql_database_instance.postgres.name}",
  "region": "${google_sql_database_instance.postgres.region}",
  "project": "${google_sql_database_instance.postgres.project}",
  "connection_name": "${google_sql_database_instance.postgres.connection_name}"
}
EOT
}

