provider google {
  alias   = "target"
  project = var.project_id
}

provider vault {
  alias = "target"
}
