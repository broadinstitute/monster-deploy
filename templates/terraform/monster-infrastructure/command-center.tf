module command_center {
  source = "../command-center-project"
  providers = {
    google.target = google.command-center,
    vault.target  = vault.target
  }

  is_production    = var.is_production
  k8s_cluster_size = var.cluster_size
  k8s_machine_type = var.machine_type
  # 4 CPU, 15 GiB of RAM.
  db_tier = var.db_tier
}
