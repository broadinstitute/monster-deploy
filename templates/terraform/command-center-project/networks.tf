module k8s_network {
  source = "/templates/compute-network"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services]

  name = "command-center-network"
  subnets = [{
    region = "us-central1",
    cidr = "10.0.0.0/22"
  }]
  enable_flow_logs = var.is_production
}
