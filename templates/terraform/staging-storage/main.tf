resource google_storage_bucket staging_bucket {
  provider = google.target
  name     = "${var.project_name}-${var.area_name}"
  location = "US"
}

module external_writer_account {
  source = "../google-sa"
  providers = {
    google.target = google.target
    vault.target  = vault.target
  }

  account_id   = var.external_writer_sa_account_name
  display_name = "Account used to interact the ${var.area_name} staging area"
  vault_path   = "${var.vault_prefix}/service-accounts/${var.external_writer_sa_account_name}"
  roles        = ["storagetransfer.user", "storagetransfer.viewer"]
}

resource google_storage_bucket_iam_member admin_group_iam {
  # optionally grant an external google group admin access as well
  count    = var.external_admin_group == null ? 0 : 1
  provider = google.target
  bucket   = google_storage_bucket.staging_bucket.name
  role     = "roles/storage.admin"
  member   = "group:${var.external_admin_group}"
}


resource google_storage_bucket_iam_member sa_writer_iam {
  provider = google.target
  bucket   = google_storage_bucket.staging_bucket.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${module.external_writer_account.email}"
}

resource google_storage_bucket_iam_member tdr_reader_iam {
  provider = google.target
  for_each = toset([var.tdr_repo_email, var.hca_dataflow_email])

  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${each.value}"
}

data google_storage_transfer_project_service_account sts_account {
  provider = google.target
}

resource google_storage_bucket_iam_member sts_iam {
  provider = google.target
  for_each = toset(["storage.legacyBucketReader", "storage.objectViewer", "storage.legacyBucketWriter"])

  bucket = google_storage_bucket.staging_bucket.name
  role   = "roles/${each.value}"
  member = "serviceAccount:${data.google_storage_transfer_project_service_account.sts_account.email}"
}

module staging_notification_pubsub_topic {
  source     = "terraform-google-modules/pubsub/google"
  version    = "~>1.8"
  project_id = var.project_id
  topic      = "${var.project_name}.staging-transfer-notifications.${var.area_name}"
  pull_subscriptions = [
    {
      name = "${var.area_name}-writer"
    }
  ]
}

resource google_pubsub_subscription_iam_member staging_writer_iam {
  provider     = google.target
  subscription = "projects/${var.project_id}/subscriptions/${var.area_name}-writer"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${module.external_writer_account.email}"
}

resource google_pubsub_topic_iam_member staging_writer_iam {
  provider = google.target
  topic    = "${var.project_name}.staging-transfer-notifications.${var.area_name}"
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${module.external_writer_account.email}"
}
