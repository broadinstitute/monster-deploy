module k8s_network {
  source = "/templates/compute-network"
  providers = {
    google.target = google.target
  }

  name = "monster-processing-network"
  subnets = [{
    region = var.region,
    cidr = "10.0.0.0/22"
  }]
  enable_flow_logs = var.is_production
}
