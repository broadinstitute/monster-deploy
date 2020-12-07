module cloudsql {
  source = "..//cloudsql"
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
  db_names = ["argo"]
  user_names = ["argo"]
  vault_prefix = local.vault_prefix
  dependencies = module.enable_services
}
