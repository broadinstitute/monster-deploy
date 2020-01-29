output email {
  value = google_service_account.sa.email
}

output delay {
  value = null_resource.sa_delay
}
