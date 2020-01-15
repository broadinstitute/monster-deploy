provider google {
  alias = "target"
}

# a gcs bucket
resource google_storage_bucket test_bucket {
  provider = google.target
  name = "PLACEHOLDER"
  location = "US"
}
# a service account
resource google_service_account test_sa {
  account_id = "PLACEHOLDER"
  display_name = "PLACEHOLDER"
  depends_on = []
}
# iam bindings to allow service account to read/write on bucket
resource google_project_iam_member test_iam {
  project = "PLACEHOLDER"
  role = "PLACEHOLDER"
  member = "PLACEHOLDER"
  depends_on = []
}
# a vault secret containing hte JSON key for hte service account
resource vault_generic_secret test_secret {
  path = "PLACEHOLDER"
  data_json = "PLACEHOLDER"
}