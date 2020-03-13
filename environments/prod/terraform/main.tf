module monster_infrastructure {
  source = "/templates/monster-infrastructure"

  env = "prod"
  cluster_size = 3
  machine_type = "n1-standard-4"
  # 4 CPU, 15 GiB of RAM.
  db_tier = "db-custom-4-15360"
}
