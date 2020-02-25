provider google-beta {
  project = "broad-dsp-monster-v2f-prod"
  region = "us-central1"
  alias = "v2f"
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
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.v2f,
    vault.target = vault.v2f
  }

  account_id = "v2f-writer"
  display_name = " Service account to write V2F data to GCS"
  vault_path = "secret/dsde/monster/prod/v2f/service-accounts/bucket-writer"
  roles = []
}

resource google_storage_bucket_iam_member v2f_iam {
  provider = google-beta.v2f
  bucket = google_storage_bucket.v2f_results_bucket.name
  role = "roles/storage.objectCreator"
  member = "serviceAccount:${module.v2f_writer.email}"
  depends_on = [module.v2f_writer.delay]
}
