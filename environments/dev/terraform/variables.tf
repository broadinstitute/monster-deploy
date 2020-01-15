variable kubeconfig_dir_path {
  type = string
  description = "Local path where all kubeconfigs generated in the environment should be written."
}

locals {
  processing_kubeconfig_dir = "${var.kubeconfig_dir_path}/processing"
  vault_prefix = "secret/dsde/monster/dev"
}
