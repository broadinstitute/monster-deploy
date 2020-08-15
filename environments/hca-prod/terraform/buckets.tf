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

resource google_storage_bucket_iam_member ebi_sa_bucket_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ebi_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  for_each = toset(["ebi-staging-writer@broad-dsp-monster-hca-dev.iam.gserviceaccount.com"])

  role = "roles/storage.admin"
  member = "serviceAccount:${each.value}"
}

# Service account for EBI to use when writing to the bucket.
module ebi_writer_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "ebi-staging-writer"
  display_name = "Account used by EBI to interact with their staging bucket"
  vault_path = "${local.prod_vault_prefix}/service-accounts/ebi-storage-writer"
  roles = ["storagetransfer.user", "storagetransfer.viewer"]
}

# EBI is an admin on their bucket.
resource google_storage_bucket_iam_member ebi_writer_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.ebi_bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.ebi_writer_account.email}"
}

# Both TDRs and our Dataflow SA can read from the bucket.
resource google_storage_bucket_iam_member tdr_reader_iam {
  provider = google-beta.target
  for_each = toset([local.dev_repo_email, local.prod_repo_email, module.hca_dataflow_account.email])

  bucket = google_storage_bucket.ebi_bucket.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${each.value}"
}

# Google's Storage Transfer Service can interact with the bucket.
data google_storage_transfer_project_service_account sts_account {
  provider = google-beta.target
}

resource google_storage_bucket_iam_member sts_iam {
  provider = google-beta.target

  bucket = google_storage_bucket.ebi_bucket.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_storage_transfer_project_service_account.sts_account.email}"
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

# temp bucket for dataflow temporary files
resource google_storage_bucket temp_bucket {
  provider = google-beta.target
  name = "${local.prod_project_name}-temp-storage"
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
  provider = google-beta.target
  bucket = google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_temp_bucket_iam {
  provider = google-beta.target
  bucket =  google_storage_bucket.temp_bucket.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

# staging bucket
resource google_storage_bucket staging_storage {
  provider = google-beta.target
  name = "${local.prod_project_name}-staging-storage"
  location = "US"
}

resource google_storage_bucket_iam_member staging_bucket_runner_iam {
  provider = google-beta.target
  bucket = google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_dataflow_account.email}"
  depends_on = [module.hca_dataflow_account.delay]
}

resource google_storage_bucket_iam_member hca_argo_staging_bucket_iam {
  provider = google-beta.target
  bucket =  google_storage_bucket.staging_storage.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}

resource google_storage_bucket_iam_member staging_account_iam_reader {
  provider = google-beta.target
  bucket = google_storage_bucket.staging_storage.name
  # Object viewer gives both 'list' and 'get' permissions to all objects in the bucket.
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${local.prod_repo_email}"
}

# Bucket for long term Argo logs storage, currently want no "delete after N days" rule.
resource google_storage_bucket hca_argo_archive {
  provider = google-beta.target
  name = "${local.prod_project_name}-argo-archive"
  location = "US"
}

resource google_storage_bucket_iam_member hca_argo_logs_bucket_iam {
  provider = google-beta.target
  bucket =  google_storage_bucket.hca_argo_archive.name
  # When the storage.admin role is applied to an individual bucket,
  # the control applies only to the specified bucket and objects within
  # the bucket: https://cloud.google.com/storage/docs/access-control/iam-roles
  role = "roles/storage.admin"
  member = "serviceAccount:${module.hca_argo_runner_account.email}"
}
# Service accounts that use these buckets
# sa w/permissions to use dataflow & bigquery
module hca_dataflow_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-dataflow-runner"
  display_name = "Service account to run HCA dataflow jobs"
  vault_path = "${local.prod_vault_prefix}/service-accounts/hca-dataflow-runner"
  roles = ["dataflow.worker"]
}

module hca_argo_runner_account {
  source = "/templates/google-sa"
  providers = {
    google.target = google-beta.target,
    vault.target = vault.target
  }

  account_id = "hca-argo-runner"
  display_name = "Service account to run HCA's Argo workflow."
  vault_path = "${local.prod_vault_prefix}/service-accounts/hca-argo-runner"
  roles = ["dataflow.developer", "compute.viewer", "bigquery.jobUser", "bigquery.dataOwner"]
}

data google_project current_project {
  provider = google-beta.target
}

resource google_service_account_iam_binding hca_workload_identity_binding {
  provider = google-beta.target

  service_account_id = module.hca_argo_runner_account.id
  role = "roles/iam.workloadIdentityUser"
  members = ["serviceAccount:${data.google_project.current_project.id}.svc.id.goog[hca/argo-runner]"]
  depends_on = [module.hca_argo_runner_account]
}

resource google_service_account_iam_binding dataflow_runner_user_binding {
  provider = google-beta.target

  service_account_id = module.hca_dataflow_account.id
  role = "roles/iam.serviceAccountUser"
  members = ["serviceAccount:${module.hca_argo_runner_account.email}"]
}
