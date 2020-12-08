module k8s_network {
  source = "../compute-network"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services]

  name = "monster-processing-network"
  subnets = [{
    region = var.region,
    cidr   = "10.0.0.0/22"
  }]
  enable_flow_logs = var.is_production
}
