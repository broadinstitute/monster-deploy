provider google-beta {
  alias = "target"

  project = local.dev_project_name
  region = "us-central1"
}

provider google {
  alias = "target"
}

provider google-beta {
  alias = "dev-core"

  project = "broad-dsp-monster-dev"
  region = "us-central1"
}

provider vault {
  alias = "target"
}
