provider google {
  project = "broad-dsp-monster-dev"
  region  = "us-central1"
  alias   = "command-center"
}

provider vault {
  alias = "command-center"
}

provider google {
  project = "broad-dsp-monster-clingen-dev"
  region  = "us-central1"
  alias   = "clinvar"
}

provider google {
  project = "broad-dsp-monster-encode-dev"
  region  = "us-west1"
  alias   = "encode"
}

provider aws {
  region = "us-east-1"
  alias  = "encode"
}

module monster_infrastructure {
  source = "../../../templates/terraform/monster-infrastructure"
  providers = {
    google.command-center = google.command-center
    vault.target          = vault.command-center
    google.clinvar        = google.clinvar
    google.encode         = google.encode,
    aws.encode            = aws.encode
  }

  is_production = false
  cluster_size  = 4
  machine_type  = "n1-standard-4"
  # 4 CPU, 15 GiB of RAM.
  db_tier = "db-custom-4-15360"
}