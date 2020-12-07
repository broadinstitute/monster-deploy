provider google-beta {
  alias = "target"

  project = local.prod_project_id
  region = "us-central1"
}
provider google-beta {
  alias = "prod-core"
  project = "broad-dsp-monster-prod"
  region = "us-central1"
}

provider vault {
  alias = "target"
}
