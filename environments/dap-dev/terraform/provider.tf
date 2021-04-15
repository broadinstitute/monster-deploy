provider google {
  alias = "target"

  project = local.dev_project_name
  region  = "us-central1"
}