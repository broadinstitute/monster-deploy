module ebi_staging_notification_pubsub_topic {
  source     = "terraform-google-modules/pubsub/google"
  version    = "~>1.8"
  project_id = local.prod_project_id
  topic      = "staging-transfer-notifications.ebi"
  pull_subscriptions = [
    {
      name = "ebi-writer"
  }]
}

# EBI can consume from the EBI transfer notifications pull subscription
resource google_pubsub_subscription_iam_member ebi_writer_iam {
  provider     = google-beta.target
  subscription = "ebi-writer"
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${module.ebi_writer_account.email}"
  depends_on   = [module.ebi_staging_notification_pubsub_topic]
}


# EBI can publish to the EBI transfer notifications topic (needed for testing on their end)
resource google_pubsub_topic_iam_member ebi_writer_iam {
  provider   = google-beta.target
  topic      = "staging-transfer-notifications.ebi"
  role       = "roles/pubsub.publisher"
  member     = "serviceAccount:${module.ebi_writer_account.email}"
  depends_on = [module.ebi_staging_notification_pubsub_topic]
}
