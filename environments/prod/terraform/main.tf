provider google-beta {
  credentials = file("../../gcs_sa_key.json")
  project = "broad-dsp-monster-prod"
  region = "us-central1"
  alias = "command-center"
}

provider vault {
  alias = "command-center"
}

provider google-beta {
  credentials = file("../../gcs_sa_key.json")
  project = "broad-dsp-monster-clingen-prod"
  region = "us-central1"
  alias = "clinvar"
}

provider google-beta {
  credentials = file("../../gcs_sa_key.json")
  project = "broad-dsp-monster-encode-prod"
  region = "us-west1"
  alias = "encode"
}

provider aws {
  region = "us-east-1"
  alias = "encode"
}

module monster_infrastructure {
  source = "../../../templates/terraform/monster-infrastructure"
  providers = {
    google.command-center = google-beta.command-center
    vault.target = vault.command-center
    google.clinvar = google-beta.clinvar
    google.encode = google-beta.encode,
    aws.encode = aws.encode
  }

  is_production = true
  cluster_size = 3
  machine_type = "n1-standard-4"
  # 4 CPU, 15 GiB of RAM.
  db_tier = "db-custom-4-15360"
}
