module cloudsql {
  source = "../../../templates/cloudsql"
  providers = {
    google.target = google-beta.target
    vault.target = vault.target
  }

  name_prefix = "command-center"
  cpu = 4
  ram = 15360
  labels = {
    app = "hca"
    role = "database"
    state = "active"
  }
  db_names = ["argo"]
  user_names = ["argo"]
  vault_prefix = local.dev_vault_prefix
  dependencies = module.enable_services
}
