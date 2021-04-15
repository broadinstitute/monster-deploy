provider google {
  alias = "target"
  project = var.project_name
}

provider vault {
  alias = "target"
}
