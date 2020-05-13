provider google-beta {
  project = local.project_name
  region = "us-central1"
  alias = "target"
}

provider vault {
  alias = "target"
}
