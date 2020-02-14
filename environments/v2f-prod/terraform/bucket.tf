provider google-beta {
  project = "broad-dsp-monster-v2f-prod"
  region = "us-central1"
  alias = "v2f"
}

resource google_storage_bucket v2f_results_bucket {
  provider = google-beta.v2f
  name = "variant-to-function-result-sets"
  location = "US"
}
