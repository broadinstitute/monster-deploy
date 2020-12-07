module command_center {
  # NOTE: This path is where we expect the template to be mounted
  # within the Docker image we run in init.sh, not where we expect
  # it to be located in the git repo.
  source = "..//command-center-project"
  providers = {
    google.target = google.command-center,
    vault.target = vault.target
  }

  is_production = var.is_production
  k8s_cluster_size = var.cluster_size
  k8s_machine_type = var.machine_type
  # 4 CPU, 15 GiB of RAM.
  db_tier = var.db_tier
}
