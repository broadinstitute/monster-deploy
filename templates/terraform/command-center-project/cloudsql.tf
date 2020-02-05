module cloudsql {
  source = "/templates/cloudsql"
  providers = {
    google.target = google.target
    vault.target = vault.target
  }

  name_prefix = "command-center"
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
  dependencies = module.enable_services
}
