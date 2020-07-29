# bucket for EBI
resource google_storage_bucket ebi_bucket {
  provider = google-beta.target
  name = "${local.prod_project_name}-ebi-storage"
  location = "US"
}

resource google_storage_bucket_iam_member ebi_bucket_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ebi_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  for_each = toset(["enrique@ebi.ac.uk", "rolando@ebi.ac.uk"])

  role = "roles/storage.admin"
  member = "user:${each.value}"
}

# bucket for UCSC
resource google_storage_bucket ucsc_bucket {
  provider = google-beta.target
  name = "${local.prod_project_name}-ucsc-storage"
  location = "US"
}

resource google_storage_bucket_iam_member ucsc_bucket_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ucsc_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  for_each = toset(["hannes@ucsc.edu", "dsotirho@ucsc.edu"])

  role = "roles/storage.admin"
  member = "user:${each.value}"
}
