output email {
  value = google_service_account.sa.email
}

output name {
  value = google_service_account.sa.name
}

output delay {
  value = null_resource.sa_delay
}

output id {
  value = google_service_account.sa.id
}
