resource google_storage_bucket storage_bucket {
  location                    = "us-central1"
  name                        = "${local.dev_project_name}-storage"
  project                     = local.dev_project_name
}