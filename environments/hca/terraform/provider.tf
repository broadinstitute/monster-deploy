provider google-beta {
  project = local.dev_project_name
  region = "us-central1"
  alias = "target"
}

provider vault {
  alias = "target"
}
