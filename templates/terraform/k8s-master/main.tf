# Needed for getting the ID of the project backing the k8s resource.
data google_project project {
  provider = google.target
}

# Create the GKE master.
# This master will have no nodes, so it won't be able to run any pods until
# a node pool is provisioned for it.
resource google_container_cluster master {
  provider = google.target

  name = var.name
  location = var.location
  depends_on = [var.dependencies]

  network = var.network
  subnetwork = var.subnetwork

  # CIS compliance: stackdriver logging
  logging_service = "logging.googleapis.com/kubernetes"

  # CIS compliance: stackdriver monitoring
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Rate-limit automatic upgrades to a few per month.
  release_channel {
    channel = "REGULAR"
  }

  lifecycle {
    ignore_changes = [
      node_pool,
      master_auth[0].client_certificate_config[0].issue_client_certificate,
      network,
      subnetwork,
    ]
  }

  # Silly, but necessary to have a default pool of 0 nodes. This allows the node definition to be handled cleanly
  # in a separate file
  remove_default_node_pool = true
  initial_node_count = 1

  # CIS compliance: disable legacy Auth
  enable_legacy_abac = false

  # CIS compliance: disable basic auth -- this creates a certificate and
  # disables basic auth by not specifying a user / pasword.
  # See https://www.terraform.io/docs/providers/google/r/container_cluster.html#master_auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
    username = ""
    password = ""
  }

  # CIS compliance: Enable Network Policy
  network_policy {
    enabled = true
  }

  ip_allocation_policy {
    # According to trial and error, setting these values to null
    # lets Google derive values that actually work.
    # Otherwise you'll end up flipping a table trying to set things manually.
    cluster_ipv4_cidr_block = null
    services_ipv4_cidr_block = null
  }

  # CIS compliance: Enable PodSecurityPolicyController
  pod_security_policy_config {
    enabled = true
  }

  workload_identity_config {
    identity_namespace = "${data.google_project.project.project_id}.svc.id.goog"
  }

  # OMISSION: CIS compliance: Enable Private Cluster
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "10.0.82.0/28"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = local.broad_network_cidrs
      content {
        cidr_block = cidr_blocks.value
      }
    }
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }
}
