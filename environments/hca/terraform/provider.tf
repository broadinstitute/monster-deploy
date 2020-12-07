provider google-beta {
  credentials = file("../../gcs_sa_key.json")
  alias = "target"

  project = local.dev_project_name
  region = "us-central1"
}

provider google-beta {
  credentials = file("../../gcs_sa_key.json")
  alias = "dev-core"

  project = "broad-dsp-monster-dev"
  region = "us-central1"
}

provider vault {
  alias = "target"
}
