provider google-beta {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
  alias = "command-center"
}

provider vault {
  alias = "command-center"
}

module monster_infrastructure {
  source = "/templates/monster-infrastructure"
  providers = {
    google.target = google-beta.command-center
    vault.target = vault.command-center
  }

  env = "dev"
  cluster_size = 3
  machine_type = "n1-standard-4"
  # 4 CPU, 15 GiB of RAM.
  db_tier = "db-custom-4-15360"
}
