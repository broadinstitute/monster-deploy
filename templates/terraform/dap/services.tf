module enable_services {
  source = "../api-services"
  providers = {
    google.target = google.target
  }
  service_ids = module.enable_services.standard_service_ids
}
