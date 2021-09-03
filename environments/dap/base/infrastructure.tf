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

variable vault_prefix {
  type = string
}

provider google {
  alias = "target"

  project = var.project_id
  region  = "us-central1"
}

provider vault {
  alias = "target"
}

variable dagster_runner_email {
  type = string
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

module dap_dataflow_account {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google.target,
    vault.target  = vault.target
  }

  account_id   = "dap-dataflow-runner"
  display_name = "Service account to run DAP dataflow jobs"
  vault_path   = "${var.vault_prefix}/service-accounts/dap-dataflow-runner"
  roles        = ["dataflow.worker", "storage.objects.admin"]
}


# temp bucket for dataflow temporary files
resource google_storage_bucket temp_bucket {
  provider = google.target
  name     = "${var.project_name}-temp-storage"
  location = "US"

  lifecycle_rule {
    action {
      type = "Delete"
    }

    # Delete files after they've been in the bucket for 7 days.
    condition {
      age = 7
    }
  }
}

resource google_storage_bucket_iam_member temp_bucket_runner_iam {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role       = "roles/storage.admin"
  member     = "serviceAccount:${module.dap_dataflow_account.email}"
  depends_on = [module.dap_dataflow_account.delay]
}


resource google_storage_bucket_iam_member staging_account_iam_reader {
  provider = google.target
  bucket   = google_storage_bucket.temp_bucket.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.dagster_runner_email}"
}
