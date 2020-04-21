provider google-beta {
  project = "broad-dsp-monster-prod"
  region = "us-central1"
  alias = "command-center"
}

provider vault {
  alias = "command-center"
}

provider google-beta {
  project = "broad-dsp-monster-clingen-prod"
  region = "us-central1"
  alias = "clinvar"
}

provider google-beta {
  project = "broad-dsp-monster-encode-prod"
  region = "us-west1"
  alias = "encode"
}

module monster_infrastructure {
  source = "/templates/monster-infrastructure"
  providers = {
    google.command-center = google-beta.command-center
    vault.target = vault.command-center
    google.clinvar = google-beta.clinvar
    google.encode = google-beta.encode
  }

  is_production = true
  cluster_size = 3
  machine_type = "n1-standard-4"
  # 4 CPU, 15 GiB of RAM.
  db_tier = "db-custom-4-15360"
}
