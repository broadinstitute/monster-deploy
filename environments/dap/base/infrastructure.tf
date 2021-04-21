variable project_name {
  # GCP project name
  type = string
}

variable project_id {
  # GCP project ID
  # project ID and name can differ i.e., ID is sometimes an auto-generated google name that
  # we do not want to use to prefix our bucket names etc., so  we expose both the ID and
  # human-friendly name
  type = string
}

provider google {
  alias = "target"

  project = var.project_id
  region  = "us-central1"
}

module enable_services {
  source = "../../../templates/terraform/api-services"
  providers = {
    google.target = google.target
  }
  service_ids = module.enable_services.standard_service_ids
}

resource google_storage_bucket storage_bucket {
  location = "us-central1"
  name     = "${var.project_name}-storage"
  project  = var.project_id
}
