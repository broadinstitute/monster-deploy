module k8s_network {
  source = "../../../templates/terraform/compute-network"
  providers = {
    google.target = google.target
  }
  dependencies = [module.enable_services]

  name = "hca-network"
  subnets = [{
    region = "us-central1",
    cidr   = "10.0.0.0/22"
  }]
  enable_flow_logs = true
}
