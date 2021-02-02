module ebi_staging_notification_pubsub_topic {
  source     = "terraform-google-modules/pubsub/google"
  version    = "~>1.8"
  project_id = local.dev_project_name
  topic      = "broad-dsp-monster-hca-dev.staging-transfer-notifications.ebi"
  pull_subscriptions = [
    {
      name = "ebi-writer"
    }
  ]
}

# EBI can consume from the EBI transfer notifications pull subscription
resource google_pubsub_subscription_iam_member ebi_writer_iam {
  provider     = google-beta.target
  subscription = "projects/broad-dsp-monster-hca-dev/subscriptions/ebi-writer"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${module.ebi_writer_account.email}"
}
