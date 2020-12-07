provider google-beta {
  project = "broad-dsp-monster-v2f-prod"
  region = "us-central1"
  alias = "v2f"
}

provider google-beta {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
  alias = "command-center"
}

provider vault {
  alias = "v2f"
}

resource google_storage_bucket v2f_results_bucket {
  provider = google-beta.v2f
  name = "variant-to-function-result-sets"
  location = "US"
}

module v2f_writer {
  source = "../../../templates/terraform/google-sa"
  providers = {
    google.target = google-beta.command-center,
    vault.target = vault.v2f
  }

  account_id = "v2f-writer"
  display_name = " Service account to write V2F data to GCS"
  vault_path = "secret/dsde/monster/prod/v2f/service-accounts/bucket-writer"
  roles = []
}

data google_project command_center {
  provider = google-beta.command-center
}

resource google_storage_bucket_iam_member v2f_iam {
  provider = google-beta.v2f
  bucket = google_storage_bucket.v2f_results_bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.v2f_writer.email}"
  depends_on = [module.v2f_writer.delay]
}

resource google_service_account_iam_binding v2f_binding_iam {
  provider = google-beta.command-center
  service_account_id = module.v2f_writer.id
  role = "roles/iam.workloadIdentityUser"

  members = ["serviceAccount:${data.google_project.command_center.name}.svc.id.goog[v2f/argo-runner]"]
}

resource google_storage_bucket_iam_member v2f_reader_iam {
  provider = google-beta.v2f
  bucket = google_storage_bucket.v2f_results_bucket.name
  role = "roles/storage.objectViewer"
  member = "group:v2fcir@broadinstitute.org"
}

resource google_storage_bucket_iam_member v2f_admin_iam {
  provider = google-beta.v2f
  bucket = google_storage_bucket.v2f_results_bucket.name
  role = "roles/storage.objectAdmin"
  member = "user:schaluva@broadinstitute.org"
}
