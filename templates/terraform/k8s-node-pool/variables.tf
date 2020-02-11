# See: https://github.com/hashicorp/terraform/issues/21418#issuecomment-495818852
variable dependencies {
  type = any
  default = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules"
}

variable enable_autoscaling {
  type = bool
  default = false
  description = "Toggle to enable autoscaling of node pool."
}

variable autoscaling {
  type = object({
    min_node_count = number
    max_node_count = number
  })
  description = "Autoscaling object to capture min and max number of nodes to provision."
}

variable taints {
  type = list(object({
    key = string
    value = string
    effect = string
  }))
  description = "List of taints to apply to the nodes in the node pool."
}

variable name {
  type = string
  description = "Name to assign to the node pool."
}

variable master_name {
  type = string
  description = "Name of the GKE master / cluster where the node pool should be provisioned."
}

variable location {
  type = string
  description = "Location where the node pool should be provisioned."
}

variable node_count {
  type = number
  description = "Number of nodes to provision in the pool."
}

variable machine_type {
  type = string
  description = "API ID for the machine type to run in the node pool."
}

variable disk_size_gb {
  type = number
  description = "Size of disk to allocate for each node in the pool."
}

variable service_account_email {
  type = string
  description = "The email address of the IAM service account that will run system pods."
}
