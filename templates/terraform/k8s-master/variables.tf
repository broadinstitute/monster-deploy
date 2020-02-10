variable dependencies {
  type = any
  default = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}

variable name {
  type = string
  description = "Name to assign to the master / GKE cluster."
}

variable location {
  type = string
  description = "Zone or region to host the cluster. NOTE: passing a region here will give you a regional cluster with 3x the number of nodes."
}

variable network {
  type = string
}

variable subnetwork {
  type = string
}

variable vault_path {
  type = string
  description = "Path in Vault where secrets for the master should be stored."
}

variable service_account_email {
  type = string
  description = "The email address of the service account."
}
