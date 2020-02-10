# Create a GKE node pool, attached to an existing master.
resource google_container_node_pool pool {
  provider   = google.target

  depends_on = [var.dependencies]
  name = var.name
  location = var.location
  cluster = var.master_name
  # node_count must be set to null if autoscaling is used
  node_count = var.node_count

  # autoscaling must be set to null if node_count is used
  dynamic "autoscaling" {
    for_each = var.autoscaling == null ? [] : [var.autoscaling]
    content {
      min_node_count = autoscaling.value["min_node_count"]
      max_node_count = autoscaling.value["max_node_count"]
    }
  }

  management {
    # CIS compliance: enable automatic repair
    auto_repair = true

    # CIS compliance: enable automatic upgrade
    auto_upgrade = true
  }

  node_config {
    # CIS compliance: COS image
    image_type = "COS"
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    service_account = var.service_account_email

    dynamic "taint" {
      for_each = var.taints == null ? [] : var.taints
      content {
        key = taint.value["key"]
        value = taint.value["value"]
        effect = taint.value["effect"]
      }
    }

    workload_metadata_config {
      # Workload Identity only works when using the metadata server.
      node_metadata = "GKE_METADATA_SERVER"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
