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
//  depends_on = [module.enable_services]

  name = "${var.name_prefix}-${random_id.cloudsql_random_id.hex}"
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
  byte_length = 16
}

resource google_sql_user db-user {
  for_each = toset(var.user_names)

  name = "${var.name_prefix}-${each.value}"
  password = random_id.db-password.hex
//  project = var.google_project
  instance = google_sql_database_instance.postgres.name
}

resource google_sql_database db {
  for_each = toset(var.db_names)

  name = "${var.name_prefix}-${each.value}"
//  project = var.google_project
  instance = google_sql_database_instance.postgres.name
  charset = "UTF8"
  collation = "en_US.UTF8"
  depends_on = [google_sql_user.db-user]
}
