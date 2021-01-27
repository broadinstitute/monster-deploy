module ebi_staging_notification_pubsub_topic {
  source     = "terraform-google-modules/pubsub/google"
  version    = "~>1.8"
  project_id = local.dev_project_name
  topic      = "broad-dsp-monster-hca-dev.staging-transfer-notifications"
  pull_subscriptions = [
    {
      name = "ebi"
    }
  ]
}
