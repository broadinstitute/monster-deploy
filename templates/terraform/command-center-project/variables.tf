variable is_production {
  type = bool
  description = "If true, production-level logging etc. will be enabled"
}

variable dns_zone_name {
  type = string
  description = "Subdomain to use for DNS in the project."
}

variable k8s_cluster_size {
  type = number
  description = "Number of nodes to run in the GKE cluster."
}

variable k8s_machine_type {
  type = string
  description = "Machine type to use in the GKE cluster."
}

variable kubeconfig_path {
  type = string
  description = "Local path where kubeconfig for the GKE cluster should be written."
}

variable db_tier {
  type = string
  description = "Machine tier for the Cloud SQL proxy instance backing command-center services."
}

variable vault_prefix {
  type = string
  description = "Path prefix for secrets written to Vault."
}
