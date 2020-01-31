module cloudsql_sa {
  source = "/templates/google-sa"
  providers = {
    google.target = google.target
  }

  account_id = "cloudsql-proxy-account"
  display_name = "CloudSQL proxy account"
  vault_path = "${var.vault_prefix}/gcs/sa-key"
  roles = ["roles/cloudsql.client"]
}

module cloudsql {
  source = "/templates/cloudsql"
  providers = {
    google.target = google.target
    vault.target = vault.target
  }

  name_prefix = "command-center"
  postgres_version = ""
  cpu = 4
  ram = 15360
  labels = {
    app = "command-center"
    role = "database"
    state = "active"
  }
  db_names = []
  user_names = []
  vault_prefix = var.vault_prefix
}
